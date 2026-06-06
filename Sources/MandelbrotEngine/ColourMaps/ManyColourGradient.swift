//
//  ManyColourGradient.swift
//  Mandelbrot
//
//  Created by gary on 06/05/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import Foundation

public struct ManyColourGradient: ColourMapProtocol {
    public var title: String {
        return "Many colour gradient: \(colourCount)"
    }
    public let pixels: [Pixel]
    public let blackPixel = Pixel(r: 0, g: 0, b: 0)

    private let colourCount: Int


    init(n: Int, colours: RGB...) {
        colourCount = colours.count
        let colourMap = try! GradientColourMap(
            title: "Many colour gradient: \(colourCount)",
            colourStops: colours,
            stepsPerSegment: n
        )
        pixels = colourMap.pixels
    }
}
