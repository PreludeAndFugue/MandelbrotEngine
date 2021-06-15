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


    func hsv_to_rgb(h: CGFloat, s: CGFloat, v: CGFloat) -> (r: UInt8, g: UInt8, b: UInt8) {
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
