//
//  ColourMapFactoryTests.swift
//  
//
//  Created by gary on 06/06/2026.
//

import XCTest
@testable import MandelbrotEngine

final class ColourMapFactoryTests: XCTestCase {
    func testFactoryIncludesSmoothGradientMaps() {
        let titles = ColourMapFactory.maps.map({ $0.title })

        XCTAssertTrue(titles.contains("Deep Smooth"))
        XCTAssertTrue(titles.contains("Solar Smooth"))
        XCTAssertTrue(titles.contains("Ice Smooth"))
    }


    func testFactoryMapsHavePixelsOrCustomPixelImplementation() {
        for colourMap in ColourMapFactory.maps where colourMap.title != "Smooth Test" {
            XCTAssertFalse(colourMap.pixels.isEmpty, "\(colourMap.title) has no preview pixels")
        }
    }
}
