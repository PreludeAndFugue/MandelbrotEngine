//
//  ColourMapProtocol.swift
//  Mandelbrot
//
//  Created by gary on 29/04/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import CoreGraphics


public protocol ColourMapProtocol {
    typealias RGB = (r: UInt8, g: UInt8, b: UInt8)

    var id: String { get }
    var title: String { get }
    var blackPixel: Pixel { get }
    var pixels: [Pixel] { get }
    var preview: [Pixel] { get }
    func pixel(from test: MandelbrotSetPoint.Test) -> Pixel
}


extension ColourMapProtocol {
    public var id: String { title }


    public var preview: [Pixel] {
        let count = pixels.count
        var output: [Pixel] = []
        for _ in 0..<count {
            output.append(contentsOf: pixels)
        }
        return output
    }

    
    public func pixel(from test: MandelbrotSetPoint.Test) -> Pixel {
        switch test {
        case .inSet:
            return blackPixel
        case .notInSet(let iterations, _):
            return pixels[iterations % pixels.count]
        }
    }
}


// MARK: - Internal

internal extension ColourMapProtocol {
    static func gradient(from: RGB, to: RGB, n: Int) -> [Pixel] {
        let dr = diff(m: to.r, n: from.r)/Double(n)
        let dg = diff(m: to.g, n: from.g)/Double(n)
        let db = diff(m: to.b, n: from.b)/Double(n)
        var (r, g, b) = (Double(from.r), Double(from.g), Double(from.b))
        var pixels: [Pixel] = []
        for _ in 0 ..< n {
            pixels.append(Pixel(r: UInt8(r), g: UInt8(g), b: UInt8(b)))
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
