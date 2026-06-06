//
//  APIMandelbrotSetTests.swift
//  
//
//  Created by gary on 06/06/2026.
//

import XCTest
@testable import MandelbrotEngine

final class APIMandelbrotSetTests: XCTestCase {
    func testStartsWithPaleCyanReferenceColour() {
        let colourMap = APIMandelbrotSet()
        let pixel = colourMap.pixels[0]

        XCTAssertEqual(pixel.r, 219)
        XCTAssertEqual(pixel.g, 254)
        XCTAssertEqual(pixel.b, 254)
    }


    func testContainsReferenceBoundaryColours() {
        let colourMap = APIMandelbrotSet()
        let pixels = colourMap.pixels

        XCTAssertTrue(pixels.contains(where: { $0.r == 250 && $0.g == 199 && $0.b == 23 }))
        XCTAssertTrue(pixels.contains(where: { $0.r == 200 && $0.g == 112 && $0.b == 30 }))
        XCTAssertTrue(pixels.contains(where: { $0.r == 31 && $0.g == 36 && $0.b == 98 }))
        XCTAssertTrue(pixels.contains(where: { $0.r == 255 && $0.g == 255 && $0.b == 255 }))
    }


    func testFactoryIncludesColourMap() {
        XCTAssertTrue(ColourMapFactory.maps.contains(where: { $0.title == "API Mandelbrot set" }))
    }
}
