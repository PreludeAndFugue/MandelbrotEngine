//
//  Pixel.swift
//  Mandelbrot
//
//  Created by gary on 03/05/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

public struct Pixel {
    var a: UInt8 = 255
    var r: UInt8
    var g: UInt8
    var b: UInt8


    public init(r: UInt8, g: UInt8, b: UInt8) {
        self.r = r
        self.g = g
        self.b = b
    }


    var isBlack: Bool {
        return r == 0 && g == 0 && b == 0
    }
}
