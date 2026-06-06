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


    func testPositionedStopsControlBandSize() throws {
        let palette = ColourPalette(
            name: "Positioned stops",
            stops: [
                ColourStop(position: 0.0, rgb: (r: 0, g: 0, b: 0)),
                ColourStop(position: 0.75, rgb: (r: 255, g: 0, b: 0)),
                ColourStop(position: 1.0, rgb: (r: 255, g: 255, b: 255))
            ]
        )
        let colourMap = try GradientColourMap(palette: palette, sampleCount: 5, isCyclic: false)

        XCTAssertEqual(colourMap.pixels[1].r, 85)
        XCTAssertEqual(colourMap.pixels[1].g, 0)
        XCTAssertEqual(colourMap.pixels[3].r, 255)
        XCTAssertEqual(colourMap.pixels[3].g, 0)
    }


    func testHSVInterpolationUsesHuePath() throws {
        let palette = ColourPalette(
            name: "HSV stops",
            stops: [
                ColourStop(position: 0.0, rgb: (r: 255, g: 0, b: 0)),
                ColourStop(position: 1.0, rgb: (r: 0, g: 255, b: 0))
            ],
            interpolation: .hsv
        )
        let colourMap = try GradientColourMap(palette: palette, sampleCount: 3, isCyclic: false)
        let pixel = colourMap.pixels[1]

        XCTAssertEqual(pixel.r, 255)
        XCTAssertEqual(pixel.g, 255)
        XCTAssertEqual(pixel.b, 0)
    }


    func testOKLabInterpolationUsesPerceptualPath() throws {
        let palette = ColourPalette(
            name: "OKLab stops",
            stops: [
                ColourStop(position: 0.0, rgb: (r: 255, g: 0, b: 0)),
                ColourStop(position: 1.0, rgb: (r: 0, g: 255, b: 0))
            ],
            interpolation: .oklab
        )
        let colourMap = try GradientColourMap(palette: palette, sampleCount: 3, isCyclic: false)
        let pixel = colourMap.pixels[1]

        XCTAssertFalse(pixel.r == 128 && pixel.g == 128 && pixel.b == 0)
    }


    func testSmoothEscapeMappingUsesFinalPoint() throws {
        let palette = ColourPalette(
            name: "Mapping stops",
            stops: [
                ColourStop(position: 0.0, rgb: (r: 10, g: 0, b: 0)),
                ColourStop(position: 1.0, rgb: (r: 250, g: 0, b: 0))
            ]
        )
        let colourMap = try GradientColourMap(
            palette: palette,
            sampleCount: 256,
            mapping: .smoothEscape,
            escapePeriod: 4,
            isCyclic: false
        )
        let firstPixel = colourMap.pixel(from: .notInSet(
            iterations: 1,
            finalPoint: ComplexNumber(x: 2, y: 0)
        ))
        let secondPixel = colourMap.pixel(from: .notInSet(
            iterations: 1,
            finalPoint: ComplexNumber(x: 100, y: 0)
        ))

        XCTAssertNotEqual(firstPixel.r, secondPixel.r)
    }


    func testPixelAtSamplesPaletteContinuously() throws {
        let palette = ColourPalette(
            name: "Continuous stops",
            stops: [
                ColourStop(position: 0.0, rgb: (r: 0, g: 0, b: 0)),
                ColourStop(position: 1.0, rgb: (r: 100, g: 0, b: 0))
            ]
        )
        let colourMap = try GradientColourMap(palette: palette, sampleCount: 2, isCyclic: false)
        let pixel = colourMap.pixel(at: 0.25)

        XCTAssertEqual(pixel.r, 25)
    }


    func testColourCurveAdjustsOutput() throws {
        let palette = ColourPalette(
            name: "Curved stops",
            stops: [
                ColourStop(position: 0.0, rgb: (r: 64, g: 64, b: 64)),
                ColourStop(position: 1.0, rgb: (r: 128, g: 128, b: 128))
            ]
        )
        let colourMap = try GradientColourMap(
            palette: palette,
            sampleCount: 2,
            curve: ColourCurve(brightness: 0.1),
            isCyclic: false
        )
        let pixel = colourMap.pixel(at: 0.0)

        XCTAssertGreaterThan(pixel.r, 64)
    }


    func testDitheringIsDeterministic() throws {
        let palette = ColourPalette(
            name: "Dithered stops",
            stops: [
                ColourStop(position: 0.0, rgb: (r: 0, g: 0, b: 0)),
                ColourStop(position: 1.0, rgb: (r: 255, g: 255, b: 255))
            ]
        )
        let colourMap = try GradientColourMap(
            palette: palette,
            sampleCount: 256,
            mapping: .smoothEscape,
            ditherStrength: 0.5,
            escapePeriod: 8,
            isCyclic: false
        )
        let test = MandelbrotSetPoint.Test.notInSet(
            iterations: 10,
            finalPoint: ComplexNumber(x: 12, y: 3)
        )

        XCTAssertEqual(colourMap.pixel(from: test).r, colourMap.pixel(from: test).r)
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


    func testInvalidSampleCountThrowsError() {
        let palette = ColourPalette(
            name: "Invalid sample count",
            stops: [
                ColourStop(position: 0.0, rgb: (r: 0, g: 0, b: 0)),
                ColourStop(position: 1.0, rgb: (r: 255, g: 255, b: 255))
            ]
        )

        XCTAssertThrowsError(
            try GradientColourMap(palette: palette, sampleCount: 0)
        ) { error in
            XCTAssertEqual(error as? GradientColourMapError, .invalidSampleCount)
        }
    }


    func testInvalidColourStopPositionsThrowError() {
        let palette = ColourPalette(
            name: "Invalid positions",
            stops: [
                ColourStop(position: 0.2, rgb: (r: 0, g: 0, b: 0)),
                ColourStop(position: 1.0, rgb: (r: 255, g: 255, b: 255))
            ]
        )

        XCTAssertThrowsError(
            try GradientColourMap(palette: palette)
        ) { error in
            XCTAssertEqual(error as? GradientColourMapError, .invalidColourStopPositions)
        }
    }
}
