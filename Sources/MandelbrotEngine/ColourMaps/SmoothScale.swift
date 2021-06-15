//
//  SmoothScale.swift
//  Mandelbrot
//
//  Created by gary on 02/05/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//
// http://stackoverflow.com/questions/369438/smooth-spectrum-for-mandelbrot-set-rendering

import CoreGraphics
import Foundation

public struct SmoothScale: ColourMapProtocol {

    static let (h1, s1, v1): (CGFloat, CGFloat, CGFloat) = (0.0, 1.0, 1.0)
    static let (h2, s2, v2): (CGFloat, CGFloat, CGFloat) = (359.0, 1.0, 1.0)

    let nColours = 500

    public let title = "Smooth scale"
    public let blackPixel = Pixel(r: 0, g: 0, b: 0)
    public let pixels: [Pixel]


    init() {
        pixels = SmoothScale.makePixels(nColours: nColours)
    }
}


// MARK: - Private

private extension SmoothScale {
    private static func makePixels(nColours: Int) -> [Pixel] {
        var pixels: [Pixel] = []
        for i in stride(from: 0.0, through: 1.0, by: 1.0/Double(nColours)) {
            let h = (h2 - h1) * CGFloat(i) + h1
            let s = (s2 - s1) * CGFloat(i) + s1
            let v = (v2 - v1) * CGFloat(i) + v1
            let (r, g, b) = hsv_to_rgb(h: h, s: s, v: v)
            pixels.append(Pixel(r: r, g: g, b: b))
        }
        return pixels
    }
}
