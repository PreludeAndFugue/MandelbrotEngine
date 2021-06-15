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

struct SmoothScale: ColourMapProtocol {

    static let (h1, s1, v1): (CGFloat, CGFloat, CGFloat) = (0.0, 1.0, 1.0)
    static let (h2, s2, v2): (CGFloat, CGFloat, CGFloat) = (360.0, 1.0, 1.0)

    let nColours = 500

    internal let title = "Smooth scale"
    internal let blackPixel = Pixel(r: 0, g: 0, b: 0)
    let pixels: [Pixel]


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


//            let colour = UIColor(hue: h, saturation: s, brightness: v, alpha: 1.0)
//            let (r, g, b, _) = colour.rgbaInt

            pixels.append(Pixel(r: r, g: g, b: b))
        }
        return pixels
    }


    private static func hsv_to_rgb(h: CGFloat, s: CGFloat, v: CGFloat) -> (r: UInt8, g: UInt8, b: UInt8) {
        let c = s * v
        let hp = h / 60
        let x = c * (1 - abs(hp.truncatingRemainder(dividingBy: 2) - 1))
        let r1: CGFloat
        let g1: CGFloat
        let b1: CGFloat
        switch hp {
        case 0...1:
            (r1, g1, b1) = (c, x, 0)
        case 1...2:
            (r1, g1, b1) = (x, c, 0)
        case 2...3:
            (r1, g1, b1) = (0, c, x)
        case 3...4:
            (r1, g1, b1) = (0, x, c)
        case 4...5:
            (r1, g1, b1) = (x, 0, c)
        case 5...6:
            (r1, g1, b1) = (c, 0, x)
        default:
            (r1, g1, b1) = (0, 0, 0)
        }
        let m = v - c
        return (UInt8(256 * (r1 + m)), UInt8(256 * (g1 + m)), UInt8(256 * (b1 + m)))
    }
}
