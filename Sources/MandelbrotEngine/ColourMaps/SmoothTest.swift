//
//  SmoothTest.swift
//  MandelbrotApp
//
//  Created by gary on 16/09/2018.
//  Copyright © 2018 Gary Kerr. All rights reserved.
//

import CoreGraphics
import Foundation

public struct SmoothTest: ColourMapProtocol {
    private let log2Value: Double = log(2)
    private let log4Value: Double = log(4)

    public let title = "Smooth Test"
    public let blackPixel = Pixel(r: 0, g: 0, b: 0)
    public let pixels: [Pixel] = []


    public func pixel(from test: MandelbrotSetPoint.Test) -> Pixel {
        switch test {
        case .inSet:
            return blackPixel
        case .notInSet(let N, let zN):
            return makePixel(N: N, zN: zN)
//            return makePixel2(N: N, zN: zN)
        }
    }
}


private extension SmoothTest {
    func makePixel(N: Int, zN: ComplexNumber) -> Pixel {
        let modulus = sqrt(zN.modulus())
        let mu = Double(N + 1) - log(log(modulus))/log2Value
//        var hue = CGFloat(0.95 + 20.0 * mu) // adjust to make it prettier
        var hue = CGFloat(mu)
        while hue > 1 {
            hue -= 1
        }
        while hue < 0.0 {
            hue += 1
        }
        let (r, g, b) = hsv_to_rgb(h: hue, s: 0.8, v: 1)
        return Pixel(r: r, g: g, b: b)
    }


    func makePixel2(N: Int, zN: ComplexNumber) -> Pixel {
        let log_zn = log(zN.modulus())
        let mu = Double(N + 1) - log(log_zn/log2Value)/log2Value
        print(mu)
        return blackPixel
    }
}
