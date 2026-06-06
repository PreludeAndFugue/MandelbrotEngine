//
//  GradientColourMapTests.swift
//  
//
//  Created by gary on 06/06/2026.
//

import XCTest
@testable import MandelbrotEngine

final class GradientColourMapTests: XCTestCase {
    func testFirstPixelEqualsFirstColourStop() throws {
        let colourMap = try GradientColourMap(
            title: "Test gradient",
            colourStops: [(r: 12, g: 34, b: 56), (r: 255, g: 255, b: 255)],
            stepsPerSegment: 4
        )
        let pixel = colourMap.pixels[0]

        XCTAssertEqual(pixel.r, 12)
        XCTAssertEqual(pixel.g, 34)
        XCTAssertEqual(pixel.b, 56)
    }


    func testIntermediateColoursAreRounded() throws {
        let colourMap = try GradientColourMap(
            title: "Rounded gradient",
            colourStops: [(r: 0, g: 0, b: 0), (r: 255, g: 255, b: 255)],
            stepsPerSegment: 2,
            isCyclic: false
        )
        let pixel = colourMap.pixels[1]

        XCTAssertEqual(pixel.r, 128)
        XCTAssertEqual(pixel.g, 128)
        XCTAssertEqual(pixel.b, 128)
    }


    func testCyclicModeIncludesFinalToFirstSegment() throws {
        let colourMap = try GradientColourMap(
            title: "Cyclic gradient",
            colourStops: [(r: 0, g: 0, b: 0), (r: 255, g: 255, b: 255)],
            stepsPerSegment: 2
        )

        XCTAssertEqual(colourMap.pixels.count, 4)
        XCTAssertEqual(colourMap.pixels[2].r, 255)
        XCTAssertEqual(colourMap.pixels[3].r, 128)
    }


    func testNonCyclicModeStopsAtLastColour() throws {
        let colourMap = try GradientColourMap(
            title: "Non-cyclic gradient",
            colourStops: [(r: 0, g: 0, b: 0), (r: 255, g: 255, b: 255)],
            stepsPerSegment: 2,
            isCyclic: false
        )
        let pixel = colourMap.pixels[colourMap.pixels.count - 1]

        XCTAssertEqual(colourMap.pixels.count, 3)
        XCTAssertEqual(pixel.r, 255)
        XCTAssertEqual(pixel.g, 255)
        XCTAssertEqual(pixel.b, 255)
    }


    func testInvalidColourStopsThrowError() {
        XCTAssertThrowsError(
            try GradientColourMap(
                title: "Invalid gradient",
                colourStops: [(r: 0, g: 0, b: 0)],
                stepsPerSegment: 2
            )
        ) { error in
            XCTAssertEqual(error as? GradientColourMapError, .notEnoughColourStops)
        }
    }


    func testInvalidStepsPerSegmentThrowsError() {
        XCTAssertThrowsError(
            try GradientColourMap(
                title: "Invalid gradient",
                colourStops: [(r: 0, g: 0, b: 0), (r: 255, g: 255, b: 255)],
                stepsPerSegment: 0
            )
        ) { error in
            XCTAssertEqual(error as? GradientColourMapError, .invalidStepsPerSegment)
        }
    }
}
