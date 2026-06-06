//
//  APIMandelbrotSet.swift
//  MandelbrotEngine
//
//  Created by gary on 06/06/2026.
//

import Foundation

public struct APIMandelbrotSet: ColourMapProtocol {
    public let title = "API Mandelbrot set"
    public let blackPixel = Pixel(r: 0, g: 0, b: 0)
    public let pixels: [Pixel]


    init() {
        pixels = APIMandelbrotSet.makePixels()
    }
}


// MARK: - Private

private extension APIMandelbrotSet {
    static let colourStops: [RGB] = [
        (r: 219, g: 254, b: 254),
        (r: 237, g: 255, b: 251),
        (r: 252, g: 243, b: 161),
        (r: 250, g: 199, b: 23),
        (r: 237, g: 154, b: 15),
        (r: 200, g: 112, b: 30),
        (r: 136, g: 66, b: 39),
        (r: 77, g: 41, b: 71),
        (r: 31, g: 36, b: 98),
        (r: 22, g: 1, b: 43),
        (r: 28, g: 142, b: 215),
        (r: 149, g: 217, b: 240),
        (r: 243, g: 249, b: 235),
        (r: 255, g: 255, b: 255),
        (r: 201, g: 156, b: 79),
        (r: 0, g: 0, b: 2),
        (r: 255, g: 255, b: 255)
    ]


    static func makePixels() -> [Pixel] {
        let numberOfSteps = 18
        let nextColourStops = Array(colourStops.dropFirst()) + [colourStops[0]]
        return zip(colourStops, nextColourStops)
            .map({ gradient(from: $0, to: $1, n: numberOfSteps) })
            .reduce([], { x, y in x + y })
    }
}
