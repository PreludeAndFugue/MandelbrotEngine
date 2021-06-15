//
//  File.swift
//  
//
//  Created by gary on 15/06/2021.
//

import XCTest
@testable import MandelbrotEngine

final class HelpersTests: XCTestCase {
    func testZero() {
        let (r, g, b) = hsv_to_rgb(h: 0, s: 0, v: 0)
        XCTAssertEqual(r, 0)
        XCTAssertEqual(g, 0)
        XCTAssertEqual(b, 0)
    }


    func testExample1() {
        let (r, g, b) = hsv_to_rgb(h: 60, s: 0.5, v: 0.5)
        XCTAssertEqual(r, 128)
        XCTAssertEqual(g, 128)
        XCTAssertEqual(b, 64)
    }


    func testExample2() {
        let (r, g, b) = hsv_to_rgb(h: 0, s: 1, v: 1)
        XCTAssertEqual(r, 255)
        XCTAssertEqual(g, 0)
        XCTAssertEqual(b, 0)
    }
}
