//
//  TumbleweedTests.swift
//  NRK
//
//  Created by Johan Sørensen on {TODAY}.
//  Copyright © 2017 NRK. All rights reserved.
//

import Foundation
import XCTest
import Tumbleweed

class TumbleweedTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //// XCTAssertEqual(Tumbleweed().text, "Hello, World!")
    }
}

#if os(Linux)
extension TumbleweedTests {
    static var allTests : [(String, (TumbleweedTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
#endif
