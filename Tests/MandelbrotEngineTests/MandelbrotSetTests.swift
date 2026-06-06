//
//  MandelbrotSetTests.swift
//  
//
//  Created by gary on 06/06/2026.
//

import Foundation
import XCTest
@testable import MandelbrotEngine

final class MandelbrotSetTests: XCTestCase {
    func testParallelGridMatchesSerialReference() {
        let config = MandelbrotSetConfig(
            imageWidth: 20,
            imageHeight: 12,
            width: 3.2,
            height: 2.4,
            centre: ComplexNumber(x: -0.5, y: 0),
            iterations: 80
        )
        var timerWasCalled = false

        let set = MandelbrotSet(config: config, progress: Progress(), timer: { _ in
            timerWasCalled = true
        })
        let serialGrid = makeSerialGrid(config: config)

        XCTAssertEqual(set.imageSize.width, config.imageWidth)
        XCTAssertEqual(set.imageSize.height, config.imageHeight)
        XCTAssertEqual(set.grid.count, config.imageWidth * config.imageHeight)
        XCTAssertEqual(set.grid.count, serialGrid.count)
        XCTAssertTrue(timerWasCalled)

        for index in 0..<serialGrid.count {
            assertEqual(set.grid[index], serialGrid[index], index: index)
        }
    }
}


// MARK: - Private

private extension MandelbrotSetTests {
    func makeSerialGrid(config: MandelbrotSetConfig) -> [MandelbrotSetPoint] {
        var grid: [MandelbrotSetPoint] = []
        grid.reserveCapacity(config.imageWidth * config.imageHeight)
        for yIndex in 0..<config.imageHeight {
            let y = config.yMin + Double(yIndex) * config.dy
            for xIndex in 0..<config.imageWidth {
                let x = config.xMin + Double(xIndex) * config.dx
                grid.append(makePoint(x: x, y: y, iterations: config.iterations))
            }
        }
        return grid
    }


    func makePoint(x: Double, y: Double, iterations: Int) -> MandelbrotSetPoint {
        let point = ComplexNumber(x: x, y: y)
        if inCardiod(x: x, y: y) {
            return MandelbrotSetPoint(point: point, test: .inSet)
        }
        return MandelbrotSetPoint(point: point, test: isInSetFast1a(x0: x, y0: y, iterations: iterations))
    }


    func isInSetFast1a(x0: Double, y0: Double, iterations: Int) -> MandelbrotSetPoint.Test {
        var x = 0.0
        var y = 0.0
        var x2 = 0.0
        var y2 = 0.0
        for i in 0..<iterations {
            if x2 + y2 > 4 {
                let finalPoint = ComplexNumber(x: x, y: y)
                return .notInSet(iterations: i, finalPoint: finalPoint)
            }
            y = 2 * x * y + y0
            x = x2 - y2 + x0
            x2 = x * x
            y2 = y * y
        }
        return .inSet
    }


    func inCardiod(x: Double, y: Double) -> Bool {
        let x2 = x * x
        let y2 = y * y
        let xy2 = x2 + y2
        if xy2 * (8 * xy2 - 3) + x <= 0.09375 {
            return true
        }
        return xy2 + 2 * x + 1 <= 0.015625
    }


    func assertEqual(_ actual: MandelbrotSetPoint, _ expected: MandelbrotSetPoint, index: Int) {
        XCTAssertEqual(actual.point.x, expected.point.x, accuracy: 1e-12, "x at index \(index)")
        XCTAssertEqual(actual.point.y, expected.point.y, accuracy: 1e-12, "y at index \(index)")

        switch (actual.test, expected.test) {
        case (.inSet, .inSet):
            break
        case (.notInSet(let actualIterations, let actualFinalPoint), .notInSet(let expectedIterations, let expectedFinalPoint)):
            XCTAssertEqual(actualIterations, expectedIterations, "iterations at index \(index)")
            XCTAssertEqual(actualFinalPoint.x, expectedFinalPoint.x, accuracy: 1e-12, "final x at index \(index)")
            XCTAssertEqual(actualFinalPoint.y, expectedFinalPoint.y, accuracy: 1e-12, "final y at index \(index)")
        default:
            XCTFail("Mismatched set status at index \(index)")
        }
    }
}
