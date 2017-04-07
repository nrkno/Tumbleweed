//
//  TumbleweedTests.swift
//  NRK
//
//  Created by Johan Sørensen on 06/04/2017.
//  Copyright © 2017 NRK. All rights reserved.
//

import Foundation
import XCTest
import Tumbleweed

class TumbleweedTests: XCTestCase {
    let printer = OutputBufferingPrinter()

    override func setUp() {
        super.setUp()
        printer.reset()
    }

    func testOutput() {
        let client = Client(printer: printer.print)

        let wait = expectation(description: "async")
        let request = URLRequest(url: URL(string: "https://httpbin.org/get")!)
        client.perform(request: request) { (data, error) in
            XCTAssert(error == nil)
            wait.fulfill()
        }

        waitForExpectations(timeout: 1.0) { (error) in
            XCTAssertEqual(self.printer.lines.count, 9)
            XCTAssertEqual(self.printer.lines[0], "Task ID: 1")
            XCTAssertEqual(self.printer.lines[1], "GET https://httpbin.org/get -> 200 application/json (redirect #0)")
            XCTAssertEqual(self.printer.lines[2], "protocol: http/1.1 proxy: false reusedconn: false fetch type: network-load")
            print("")
            print(self.printer.lines.joined(separator: "\n"))
            print("")
        }
    }
}

final class OutputBufferingPrinter {
    private(set) var lines: [String] = []

    func print(_ line: String) {
        lines.append(line)
    }

    func reset() {
        lines.removeAll()
    }
}

final class Client {
    let session: URLSession

    init(printer: @escaping (String) -> Void) {
        let delegate = SessionDelegate(printer: printer)
        self.session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
    }

    func perform(request: URLRequest, completion: @escaping (Data?, Error?) -> Void) {
        let task = session.dataTask(with: request) { (data, response, error) in
            completion(data, error)
        }
        task.resume()
    }
}

final class SessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    let printer: (String) -> Void

    init(printer: @escaping (String) -> Void) {
        self.printer = printer
        super.init()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        let stats = Tumbleweed(sessionTaskMetrics: metrics, task: task)
        var renderer = ConsoleRenderer()
        renderer.printer = self.printer
        stats.render(with: renderer)
    }
}
