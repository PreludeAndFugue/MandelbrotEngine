//
//  MandelbrotSet.swift
//  Mandelbrot
//
//  Created by gary on 29/04/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import Foundation

/// Mandelbrot set calculation
///
/// Links for improvements
/// ----------------------
///
/// https://en.wikibooks.org/wiki/Fractals/Iterations_in_the_complex_plane/Mandelbrot_set#Real_Escape_Time
///
/// http://www.mrob.com/pub/muency/speedimprovements.html
///
/// https://en.wikipedia.org/wiki/Plotting_algorithms_for_the_Mandelbrot_set
///
public struct MandelbrotSet {

    let config: MandelbrotSetConfig

    public var grid: [MandelbrotSetPoint] = []
    public var imageSize: (width: Int, height: Int)


    public init(config: MandelbrotSetConfig, progress: Progress, timer: @escaping Timer.Action) {
        self.config = config
        let ys = Array(stride(from: config.yMin, to: config.yMax, by: config.dy))
        let xs = Array(stride(from: config.xMin, to: config.xMax, by: config.dx))
        imageSize = (xs.count, ys.count)
        grid.reserveCapacity(xs.count * ys.count)

        let progressHelper = ProgressHelper(steps: imageSize.height, progress: progress)
        let timerHelper = Timer(action: timer)

        for (i, y) in ys.enumerated() {
            for x in xs {
                let z = ComplexNumber(x: x, y: y)

                if inCardiod(x: x, y: y) {
                    let result = MandelbrotSetPoint(point: z, test: .inSet)
                    grid.append(result)
                    continue
                }

                let result = MandelbrotSetPoint(point: z, test: isInSetFast1a(x0: x, y0: y))
                grid.append(result)
            }
            progressHelper.update(step: i)
        }
        timerHelper.end()
    }


    public func gridIterations(config: MandelbrotSetConfig) -> Int {
        var total = 0
        for point in grid {
            switch point.test {
            case .inSet:
                total += config.iterations
            case .notInSet(let iterations, _):
                total += iterations
            }
        }
        return total
    }
}


// MARK: - Is in set tests

private extension MandelbrotSet {
    func isInSet(point: ComplexNumber) -> MandelbrotSetPoint.Test {
        var z = point
        for i in 0 ..< config.iterations {
            if z.modulus() >= 4 {
                return .notInSet(iterations: i, finalPoint: z)
            }
            z = z*z + point
        }
        return .inSet
    }


    // Maybe this could be faster because not using operator overloading on the ComplexNumber struct
    func isInSetFast(point: ComplexNumber) -> MandelbrotSetPoint.Test {
        let (u, v) = (point.x, point.y)
        var (x, y) = (point.x, point.y)
        for i in 0 ..< config.iterations {
            if x*x + y*y >= 4 {
                return .notInSet(iterations: i, finalPoint: ComplexNumber(x: x, y: y))
            }
            (x, y) = (x*x - y*y + u, 2*x*y + v)
        }
        return .inSet
    }



    /// Calculates `MandelbrotSetPoint.Test` for a complex number
    ///
    /// https://en.wikipedia.org/wiki/Plotting_algorithms_for_the_Mandelbrot_set#Optimized_escape_time_algorithms
    ///
    /// - Parameter point: The complex number
    /// - Returns: The result
    func isInSetFast1(point: ComplexNumber) -> MandelbrotSetPoint.Test {
        let x0 = point.x
        let y0 = point.y
        var x = 0.0
        var y = 0.0
        var x2 = 0.0
        var y2 = 0.0
        var w = 0.0
        for i in 0..<config.iterations {
            if x2 + y2 > 4 {
                let z_i = ComplexNumber(x: x, y: y)
                return .notInSet(iterations: i, finalPoint: z_i)
            }
            x = x2 - y2 + x0
            y = w - x2 - y2 + y0
            x2 = x * x
            y2 = y * y
            w = (x + y) * (x + y)
        }
        return .inSet
    }


    /// Calculates `MandelbrotSetPoint.Test` for a complex number
    ///
    /// https://en.wikipedia.org/wiki/Plotting_algorithms_for_the_Mandelbrot_set#Optimized_escape_time_algorithms
    ///
    /// - Parameter point: The complex number
    /// - Returns: The result
    @inline(__always)
    func isInSetFast1a(x0: Double, y0: Double) -> MandelbrotSetPoint.Test {
        var x = 0.0
        var y = 0.0
        var x2 = 0.0
        var y2 = 0.0
        for i in 0..<config.iterations {
            if x2 + y2 > 4 {
                let z_i = ComplexNumber(x: x, y: y)
                return .notInSet(iterations: i, finalPoint: z_i)
            }
            y = 2 * x * y + y0
            x = x2 - y2 + x0
            x2 = x * x
            y2 = y * y
        }
        return .inSet
    }
}


// MARK: - Cardiod checks

private extension MandelbrotSet {
    /// Is a point in the main Mandelbrot bulbs?
    ///
    /// Main cardioid
    /// https://www.reenigne.org/blog/algorithm-for-mandelbrot-cardioid/
    ///
    ///     |c|^2 (8|c|^2 - 3) + Re(c) <= 3/32
    ///
    /// First bulb:
    ///
    ///     (x + 1)^2 + y^2 <= 1/16
    ///
    func inCardiod(x: Double, y: Double) -> Bool {
        // main cardioid check
        let x2 = x * x
        let y2 = y * y
        let xy2 = x2 + y2
        if xy2 * (8 * xy2 - 3) + x <= 0.09375 {
            return true
        }

        // bulb at c = -1, with radius 1/4
//        let x1_2 = (x + 1) * (x + 1)
//        return x1_2 + y2 < 0.015625
        return xy2 + 2*x + 1 <= 0.015625
    }
}


// MARK: - Private: average pixel colour

private extension MandelbrotSet {
    func resample(pixels: [Pixel]) -> [Pixel] {
        var newPixels: [Pixel] = []
        let width = config.imageWidth
        let maxValue = config.imageWidth * config.imageHeight
        for (i, pixel) in pixels.enumerated() {
            if pixel.isBlack {
                newPixels.append(pixel)
                continue
            }
            var neighbours = getNeighbours(index: i, pixels: pixels, width: width, maxValue: maxValue)
            neighbours.append(pixel)
            let averagePixel = getAverage(pixels: neighbours)
            newPixels.append(averagePixel)
        }
        return newPixels
    }


    func getNeighbours(index: Int, pixels: [Pixel], width: Int, maxValue: Int) -> [Pixel] {
        var neighbours: [Pixel] = []
        // Left
        let left = index - 1
        if index % width != 0 {
            neighbours.append(pixels[left])
        }
        // Right
        let right = index + 1
        if right % width != 0 && right < maxValue {
            neighbours.append(pixels[right])
        }
        // Top
        let top = index - width
        if top >= 0 {
            neighbours.append(pixels[top])
        }
        // Bottom
        let bottom = index + width
        if bottom < maxValue {
            neighbours.append(pixels[bottom])
        }
        return neighbours
    }


    func getAverage(pixels: [Pixel]) -> Pixel {
        var r = 0
        var g = 0
        var b = 0
        for pixel in pixels {
            r += Int(pixel.r)
            g += Int(pixel.g)
            b += Int(pixel.b)
        }
        let count = Double(pixels.count)
        let averageR = UInt8(Double(r)/count)
        let averageG = UInt8(Double(g)/count)
        let averageB = UInt8(Double(b)/count)
        return Pixel(r: averageR, g: averageG, b: averageB)
    }
}
