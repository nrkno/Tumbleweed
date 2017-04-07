//
//  RenderTests.swift
//  Tumbleweed
//
//  Created by Johan Sørensen on 07/04/2017.
//  Copyright © 2017 NRK. All rights reserved.
//

import XCTest
@testable import Tumbleweed

class RenderTests: XCTestCase {
    let metric = Metric(transactionMetrics: TestMeasurable())
    let printer = OutputBufferingPrinter()
    var renderer: ConsoleRenderer!

    override func setUp() {
        super.setUp()
        printer.reset()
        renderer = ConsoleRenderer()
        renderer.printer = printer.print
    }

    func testHeader() {
        let output = renderer.renderHeader(with: metric)
        XCTAssertEqual(output, "GET http://example.com -> 200 text/plain, through network-load")
    }

    func testMeta() {
        let output = renderer.renderMeta(with: metric)
        XCTAssertEqual(output, "protocol: HTTP/1.1 proxy: false reusedconn: false")
    }

    func testDuration() {
        let duration = Metric.Duration(type: .domainLookup, interval: DateInterval(start: seconds(ago: 3), end: seconds(ago: 2)))
        let total = DateInterval(start: seconds(ago: 3), end: seconds(ago: 0))
        let output = renderer.renderDuration(line: duration, total: total)
        XCTAssertEqual(output, "domain lookup     |###########################                                                     |1000.0ms")
    }

    func testTotalDuration() {
        let duration1 = Metric.Duration(type: .request, interval: DateInterval(start: seconds(ago: 3), end: seconds(ago: 2)))
        let duration2 = Metric.Duration(type: .response, interval: DateInterval(start: seconds(ago: 2), end: seconds(ago: 1)))
        let metric = Metric(transactionMetrics: TestMeasurable(), durations: [duration1, duration2])
        let total = renderer.totalDateInterval(from: metric)
        XCTAssert(total != nil)
        XCTAssertEqual(total!, DateInterval(start: duration1.interval.start, end: duration2.interval.end))
    }

    func testSummary() {
        let interval = DateInterval(start: seconds(ago: 3), end: seconds(ago: 0))
        let output = renderer.renderMetricSummary(for: interval)
        XCTAssertEqual(output, "                                                                                            total   3000.0ms")
    }
}

let now = Date()
func seconds(ago: Int, from: Date = now) -> Date {
    return Calendar.current.date(byAdding: DateComponents(second: -ago), to: from)!
}

class TestMeasurable: Measurable {
    var request: URLRequest = URLRequest(url: URL(string: "http://example.com")!)
    var response: URLResponse? = HTTPURLResponse(url: URL(string: "http://example.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "text/plain"])

    var networkProtocolName: String? = "HTTP/1.1"
    var isProxyConnection: Bool = false
    var isReusedConnection: Bool = false
    var resourceFetchType: URLSessionTaskMetrics.ResourceFetchType = .networkLoad

    var domainLookupStartDate: Date? = seconds(ago: 10)
    var domainLookupEndDate: Date? = seconds(ago: 9)

    var connectStartDate: Date? = seconds(ago: 8)
    var connectEndDate: Date? = seconds(ago: 6)
    var secureConnectionStartDate: Date? = seconds(ago: 7)
    var secureConnectionEndDate: Date? = seconds(ago:6)

    var requestStartDate: Date? = seconds(ago: 4)
    var requestEndDate: Date? = seconds(ago: 3)
    var responseStartDate: Date? = seconds(ago: 2)
    var responseEndDate: Date? = seconds(ago: 1)
}
