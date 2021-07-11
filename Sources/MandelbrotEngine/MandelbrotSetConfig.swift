//
//  MandelbrotSetConfig.swift
//  Mandelbrot
//
//  Created by gary on 03/05/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

public struct MandelbrotSetConfig: CustomStringConvertible {
    public let imageWidth: Int
    public let imageHeight: Int
    public let iterations: Int
    public let width: Double
    public let height: Double
    public let centre: ComplexNumber


    init(imageWidth: Int, imageHeight: Int, width: Double, height: Double, centre: ComplexNumber, iterations: Int) {
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.width = width
        self.height = height
        self.centre = centre
        self.iterations = iterations
    }


    public init(imageWidth: Int, imageHeight: Int) {
        let centre = ComplexNumber(x: -0.5, y: 0)
        let height: Double = 4
        let width = height * Double(imageWidth) / Double(imageHeight)
        self.init(
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            width: width,
            height: height,
            centre: centre,
            iterations: 300
        )
    }

    public var xMin: Double {
        return centre.x - width/2
    }

    public var xMax: Double {
        return centre.x + width/2
    }

    public var yMin: Double {
        return centre.y - height/2
    }

    public var yMax: Double {
        return centre.y + height/2
    }

    public var dx: Double {
        return width/Double(imageWidth)
    }

    public var dy: Double {
        return height/Double(imageHeight)
    }

    public var description: String {
        return "Config(imageWidth: \(imageWidth), imageHeight: \(imageHeight), width: \(width), height: \(height), centre: \(centre), iterations: \(iterations), xMin: \(xMin), xMax: \(xMax), yMin: \(yMin), yMax: \(yMax), dx: \(dx), dy: \(dy))"
    }

    func description(set: MandelbrotSet) -> String {
        let totalIterations = set.gridIterations(config: self)
        let averageIterations = Double(totalIterations) / Double(imageWidth * imageHeight)
        return "dx:\n\(xMax - xMin)\n\ndy:\n\(yMax - yMin)\n\nmax iterations:\n\(iterations)\n\ntotal iterations:\n\(totalIterations)\n\nav. per pixel:\n\(averageIterations)"
    }


    public func zoomIn(centre: ComplexNumber) -> MandelbrotSetConfig {
        return MandelbrotSetConfig(
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            width: width/2,
            height: height/2,
            centre: centre,
            iterations: Int(1.2*Double(iterations))
        )
    }
}
