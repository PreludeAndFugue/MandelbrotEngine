//
//  ManyColourGradient.swift
//  Mandelbrot
//
//  Created by gary on 06/05/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import Foundation

struct ManyColourGradient: ColourMapProtocol {

    var title: String {
        return "Many colour gradient: \(colourCount)"
    }
    
    internal let pixels: [Pixel]
    internal let blackPixel = Pixel(r: 0, g: 0, b: 0)

    private let colourCount: Int


    init(n: Int, colours: RGB...) {
        colourCount = colours.count
        var secondColours = Array(colours[1 ... colours.count - 1])
        secondColours.append(colours.first!)
        pixels = zip(colours, secondColours)
            .map({ ManyColourGradient.gradient(from: $0, to: $1, n: n) })
            .reduce([], { x, y in x + y })
    }
}
