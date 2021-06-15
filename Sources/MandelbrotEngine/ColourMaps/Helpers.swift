//
//  File.swift
//  
//
//  Created by gary on 15/06/2021.
//

import CoreGraphics

func hsv_to_rgb(h: CGFloat, s: CGFloat, v: CGFloat) -> (r: UInt8, g: UInt8, b: UInt8) {
    let c = s * v
    let hp = h / 60
    let x = c * (1 - abs(hp.truncatingRemainder(dividingBy: 2) - 1))
    let r1: CGFloat
    let g1: CGFloat
    let b1: CGFloat
    switch hp {
    case 0..<1:
        (r1, g1, b1) = (c, x, 0)
    case 1..<2:
        (r1, g1, b1) = (x, c, 0)
    case 2..<3:
        (r1, g1, b1) = (0, c, x)
    case 3..<4:
        (r1, g1, b1) = (0, x, c)
    case 4..<5:
        (r1, g1, b1) = (x, 0, c)
    case 5..<6:
        (r1, g1, b1) = (c, 0, x)
    default:
        (r1, g1, b1) = (0, 0, 0)
    }
    let m = v - c
    return (UInt8(255 * (r1 + m)), UInt8(255 * (g1 + m)), UInt8(255 * (b1 + m)))
}
