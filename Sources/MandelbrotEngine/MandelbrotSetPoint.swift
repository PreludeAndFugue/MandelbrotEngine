//
//  MandelbrotSetPoint.swift
//  Mandelbrot
//
//  Created by gary on 29/04/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import Foundation


public struct MandelbrotSetPoint {
    public enum Test {
        case inSet
        case notInSet(iterations: Int, finalPoint: ComplexNumber)
    }

    let point: ComplexNumber
    var test: Test
}
