//
//  GradientColourMap.swift
//  MandelbrotEngine
//
//  Created by gary on 06/06/2026.
//

import Foundation

public enum GradientColourMapError: Error, Equatable {
    case notEnoughColourStops
    case invalidStepsPerSegment
}


public struct GradientColourMap: ColourMapProtocol {
    public let title: String
    public let blackPixel: Pixel
    public let pixels: [Pixel]


    public init(
        title: String,
        blackPixel: Pixel = Pixel(r: 0, g: 0, b: 0),
        colourStops: [RGB],
        stepsPerSegment: Int,
        isCyclic: Bool = true
    ) throws {
        guard colourStops.count >= 2 else {
            throw GradientColourMapError.notEnoughColourStops
        }
        guard stepsPerSegment > 0 else {
            throw GradientColourMapError.invalidStepsPerSegment
        }

        self.title = title
        self.blackPixel = blackPixel
        self.pixels = GradientColourMap.makePixels(
            colourStops: colourStops,
            stepsPerSegment: stepsPerSegment,
            isCyclic: isCyclic
        )
    }
}


// MARK: - Private

private extension GradientColourMap {
    static func makePixels(colourStops: [RGB], stepsPerSegment: Int, isCyclic: Bool) -> [Pixel] {
        let nextColourStops: [RGB]
        if isCyclic {
            nextColourStops = Array(colourStops.dropFirst()) + [colourStops[0]]
        } else {
            nextColourStops = Array(colourStops.dropFirst())
        }

        let pixels = zip(colourStops, nextColourStops)
            .map({ gradient(from: $0, to: $1, steps: stepsPerSegment) })
            .reduce([], { x, y in x + y })
        if isCyclic {
            return pixels
        }
        let lastColourStop = colourStops[colourStops.count - 1]
        return pixels + [Pixel(r: lastColourStop.r, g: lastColourStop.g, b: lastColourStop.b)]
    }


    static func gradient(from: RGB, to: RGB, steps: Int) -> [Pixel] {
        let dr = diff(m: to.r, n: from.r) / Double(steps)
        let dg = diff(m: to.g, n: from.g) / Double(steps)
        let db = diff(m: to.b, n: from.b) / Double(steps)
        var (r, g, b) = (Double(from.r), Double(from.g), Double(from.b))
        var pixels: [Pixel] = []
        for _ in 0..<steps {
            pixels.append(Pixel(r: UInt8(r.rounded()), g: UInt8(g.rounded()), b: UInt8(b.rounded())))
            r += dr
            g += dg
            b += db
        }
        return pixels
    }


    static func diff(m: UInt8, n: UInt8) -> Double {
        return Double(m) - Double(n)
    }
}
