//
//  GradientColourMap.swift
//  MandelbrotEngine
//
//  Created by gary on 06/06/2026.
//

import CoreGraphics
import Foundation

public enum ColourInterpolation {
    case rgb
    case hsv
    case oklab
}


public enum ColourMapping {
    case iterationModulo
    case smoothEscape
}


public struct ColourCurve {
    public static let identity = ColourCurve()

    public let contrast: Double
    public let brightness: Double
    public let gamma: Double
    public let saturation: Double


    public init(
        contrast: Double = 1.0,
        brightness: Double = 0.0,
        gamma: Double = 1.0,
        saturation: Double = 1.0
    ) {
        self.contrast = contrast
        self.brightness = brightness
        self.gamma = gamma
        self.saturation = saturation
    }
}


public struct ColourStop {
    public let position: Double
    public let colour: Pixel


    public init(position: Double, colour: Pixel) {
        self.position = position
        self.colour = colour
    }


    public init(position: Double, rgb: ColourMapProtocol.RGB) {
        self.init(position: position, colour: Pixel(r: rgb.r, g: rgb.g, b: rgb.b))
    }
}


public struct ColourPalette {
    public let name: String
    public let stops: [ColourStop]
    public let interpolation: ColourInterpolation


    public init(name: String, stops: [ColourStop], interpolation: ColourInterpolation = .rgb) {
        self.name = name
        self.stops = stops
        self.interpolation = interpolation
    }
}


public enum GradientColourMapError: Error, Equatable {
    case notEnoughColourStops
    case invalidStepsPerSegment
    case invalidSampleCount
    case invalidColourStopPositions
}


public struct GradientColourMap: ColourMapProtocol {
    public let title: String
    public let blackPixel: Pixel
    public let pixels: [Pixel]
    public let mapping: ColourMapping
    public let palette: ColourPalette
    public let curve: ColourCurve
    public let ditherStrength: Double
    public let escapePeriod: Double
    public let isCyclic: Bool


    public init(
        title: String,
        blackPixel: Pixel = Pixel(r: 0, g: 0, b: 0),
        colourStops: [RGB],
        stepsPerSegment: Int,
        isCyclic: Bool = true
    ) throws {
        guard colourStops.count >= 2 else {
            throw GradientColourMapError.notEnoughColourStops
        }
        guard stepsPerSegment > 0 else {
            throw GradientColourMapError.invalidStepsPerSegment
        }

        let palette = ColourPalette(
            name: title,
            stops: colourStops.enumerated().map({ index, rgb in
                ColourStop(position: Double(index) / Double(colourStops.count - 1), rgb: rgb)
            })
        )

        self.title = title
        self.blackPixel = blackPixel
        self.mapping = .iterationModulo
        self.palette = palette
        self.curve = .identity
        self.ditherStrength = 0.0
        self.escapePeriod = Double(GradientColourMap.sampleCount(
            colourStopCount: colourStops.count,
            stepsPerSegment: stepsPerSegment,
            isCyclic: isCyclic
        ))
        self.isCyclic = isCyclic
        self.pixels = GradientColourMap.makePixels(
            palette: palette,
            sampleCount: GradientColourMap.sampleCount(
                colourStopCount: colourStops.count,
                stepsPerSegment: stepsPerSegment,
                isCyclic: isCyclic
            ),
            isCyclic: isCyclic,
            curve: .identity
        )
    }


    public init(
        title: String? = nil,
        palette: ColourPalette,
        sampleCount: Int = 512,
        blackPixel: Pixel = Pixel(r: 0, g: 0, b: 0),
        mapping: ColourMapping = .iterationModulo,
        curve: ColourCurve = .identity,
        ditherStrength: Double = 0.0,
        escapePeriod: Double = 64.0,
        isCyclic: Bool = true
    ) throws {
        guard sampleCount > 0 else {
            throw GradientColourMapError.invalidSampleCount
        }
        try GradientColourMap.validate(palette: palette)

        self.title = title ?? palette.name
        self.blackPixel = blackPixel
        self.mapping = mapping
        self.palette = palette
        self.curve = curve
        self.ditherStrength = ditherStrength
        self.escapePeriod = escapePeriod
        self.isCyclic = isCyclic
        self.pixels = GradientColourMap.makePixels(
            palette: palette,
            sampleCount: sampleCount,
            isCyclic: isCyclic,
            curve: curve
        )
    }


    public func pixel(from test: MandelbrotSetPoint.Test) -> Pixel {
        switch test {
        case .inSet:
            return blackPixel
        case .notInSet(let iterations, let finalPoint):
            switch mapping {
            case .iterationModulo:
                return pixels[iterations % pixels.count]
            case .smoothEscape:
                return pixel(at: smoothPosition(iterations: iterations, finalPoint: finalPoint))
            }
        }
    }


    public func pixel(at position: Double) -> Pixel {
        let wrappedPosition = wrapped(position)
        let pixel = samplePalette(position: wrappedPosition)
        return GradientColourMap.apply(curve: curve, to: pixel)
    }
}


// MARK: - Private

private extension GradientColourMap {
    static func validate(palette: ColourPalette) throws {
        guard palette.stops.count >= 2 else {
            throw GradientColourMapError.notEnoughColourStops
        }
        guard palette.stops.first?.position == 0.0,
              palette.stops.last?.position == 1.0 else {
            throw GradientColourMapError.invalidColourStopPositions
        }
        var previousPosition = -Double.infinity
        for stop in palette.stops {
            guard stop.position >= 0.0,
                  stop.position <= 1.0,
                  stop.position > previousPosition else {
                throw GradientColourMapError.invalidColourStopPositions
            }
            previousPosition = stop.position
        }
    }


    static func sampleCount(colourStopCount: Int, stepsPerSegment: Int, isCyclic: Bool) -> Int {
        if isCyclic {
            return colourStopCount * stepsPerSegment
        }
        return (colourStopCount - 1) * stepsPerSegment + 1
    }


    static func makePixels(
        palette: ColourPalette,
        sampleCount: Int,
        isCyclic: Bool,
        curve: ColourCurve
    ) -> [Pixel] {
        let count = max(sampleCount, 1)
        if count == 1 {
            return [apply(curve: curve, to: palette.stops[0].colour)]
        }
        let wrapSpan = palette.stops[palette.stops.count - 1].position - palette.stops[palette.stops.count - 2].position
        let cyclicLength = 1.0 + wrapSpan
        return (0..<count).map { index in
            let pixel: Pixel
            if isCyclic {
                let position = Double(index) / Double(count) * cyclicLength
                if position > 1.0 {
                    pixel = sampleWrapped(palette: palette, position: position, wrapSpan: wrapSpan)
                } else {
                    pixel = sample(palette: palette, position: position)
                }
            } else {
                let position = Double(index) / Double(count - 1)
                pixel = sample(palette: palette, position: position)
            }
            return apply(curve: curve, to: pixel)
        }
    }


    static func sampleWrapped(palette: ColourPalette, position: Double, wrapSpan: Double) -> Pixel {
        let segmentPosition = (position - 1.0) / wrapSpan
        return interpolate(
            from: palette.stops[palette.stops.count - 1].colour,
            to: palette.stops[0].colour,
            position: segmentPosition,
            interpolation: palette.interpolation
        )
    }


    static func sample(palette: ColourPalette, position: Double) -> Pixel {
        if position <= 0.0 {
            return palette.stops[0].colour
        }
        if position >= 1.0 {
            return palette.stops[palette.stops.count - 1].colour
        }

        for index in 0..<(palette.stops.count - 1) {
            let lowerStop = palette.stops[index]
            let upperStop = palette.stops[index + 1]
            if position >= lowerStop.position && position <= upperStop.position {
                let span = upperStop.position - lowerStop.position
                let segmentPosition = (position - lowerStop.position) / span
                return interpolate(
                    from: lowerStop.colour,
                    to: upperStop.colour,
                    position: segmentPosition,
                    interpolation: palette.interpolation
                )
            }
        }
        return palette.stops[palette.stops.count - 1].colour
    }


    static func interpolate(
        from: Pixel,
        to: Pixel,
        position: Double,
        interpolation: ColourInterpolation
    ) -> Pixel {
        switch interpolation {
        case .rgb:
            return interpolateRGB(from: from, to: to, position: position)
        case .hsv:
            return interpolateHSV(from: from, to: to, position: position)
        case .oklab:
            return interpolateOKLab(from: from, to: to, position: position)
        }
    }


    static func interpolateRGB(from: Pixel, to: Pixel, position: Double) -> Pixel {
        let r = interpolate(Double(from.r), Double(to.r), position)
        let g = interpolate(Double(from.g), Double(to.g), position)
        let b = interpolate(Double(from.b), Double(to.b), position)
        return Pixel(r: UInt8(r.rounded()), g: UInt8(g.rounded()), b: UInt8(b.rounded()))
    }


    static func interpolateHSV(from: Pixel, to: Pixel, position: Double) -> Pixel {
        let start = hsv(from: from)
        let end = hsv(from: to)
        let hueDelta = shortestHueDelta(from: start.h, to: end.h)
        let h = normalizedHue(start.h + hueDelta * position)
        let s = interpolate(start.s, end.s, position)
        let v = interpolate(start.v, end.v, position)
        let rgb = hsv_to_rgb(h: CGFloat(h), s: CGFloat(s), v: CGFloat(v))
        return Pixel(r: rgb.r, g: rgb.g, b: rgb.b)
    }


    static func interpolateOKLab(from: Pixel, to: Pixel, position: Double) -> Pixel {
        let start = oklab(from: from)
        let end = oklab(from: to)
        let l = interpolate(start.l, end.l, position)
        let a = interpolate(start.a, end.a, position)
        let b = interpolate(start.b, end.b, position)
        return pixelFromOKLab(l: l, a: a, b: b)
    }


    static func diff(m: UInt8, n: UInt8) -> Double {
        return Double(m) - Double(n)
    }


    static func interpolate(_ from: Double, _ to: Double, _ position: Double) -> Double {
        return from + (to - from) * position
    }


    func smoothPosition(iterations: Int, finalPoint: ComplexNumber) -> Double {
        let modulus = sqrt(finalPoint.modulus())
        guard modulus > 1 else {
            return wrapped(Double(iterations) / escapePeriod)
        }
        let smoothIteration = Double(iterations + 1) - log(log(modulus)) / log(2)
        let dither = ditherOffset(iterations: iterations, finalPoint: finalPoint)
        return wrapped((smoothIteration + dither) / escapePeriod)
    }


    func ditherOffset(iterations: Int, finalPoint: ComplexNumber) -> Double {
        guard ditherStrength > 0 else {
            return 0
        }
        let value = deterministicUnitValue(iterations: iterations, finalPoint: finalPoint)
        return (value - 0.5) * ditherStrength
    }


    func deterministicUnitValue(iterations: Int, finalPoint: ComplexNumber) -> Double {
        var hash = UInt64(bitPattern: Int64(iterations))
        hash ^= finalPoint.x.bitPattern &* 0x9E3779B185EBCA87
        hash ^= finalPoint.y.bitPattern &* 0xC2B2AE3D27D4EB4F
        hash ^= hash >> 33
        hash &*= 0xff51afd7ed558ccd
        hash ^= hash >> 33
        hash &*= 0xc4ceb9fe1a85ec53
        hash ^= hash >> 33
        return Double(hash & 0xFFFF) / Double(0xFFFF)
    }


    func wrapped(_ position: Double) -> Double {
        if isCyclic {
            var output = position.truncatingRemainder(dividingBy: 1.0)
            if output < 0 {
                output += 1.0
            }
            return output
        }
        return GradientColourMap.clamp(position)
    }


    func samplePalette(position: Double) -> Pixel {
        guard isCyclic else {
            return GradientColourMap.sample(palette: palette, position: position)
        }
        let wrapSpan = palette.stops[palette.stops.count - 1].position - palette.stops[palette.stops.count - 2].position
        let cyclicLength = 1.0 + wrapSpan
        let cyclicPosition = position * cyclicLength
        if cyclicPosition > 1.0 {
            return GradientColourMap.sampleWrapped(
                palette: palette,
                position: cyclicPosition,
                wrapSpan: wrapSpan
            )
        }
        return GradientColourMap.sample(palette: palette, position: cyclicPosition)
    }


    static func hsv(from pixel: Pixel) -> (h: Double, s: Double, v: Double) {
        let r = Double(pixel.r) / 255.0
        let g = Double(pixel.g) / 255.0
        let b = Double(pixel.b) / 255.0
        let maximum = max(r, g, b)
        let minimum = min(r, g, b)
        let delta = maximum - minimum

        let hue: Double
        if delta == 0 {
            hue = 0
        } else if maximum == r {
            hue = 60 * ((g - b) / delta).truncatingRemainder(dividingBy: 6)
        } else if maximum == g {
            hue = 60 * (((b - r) / delta) + 2)
        } else {
            hue = 60 * (((r - g) / delta) + 4)
        }
        let saturation = maximum == 0 ? 0 : delta / maximum
        return (normalizedHue(hue), saturation, maximum)
    }


    static func shortestHueDelta(from: Double, to: Double) -> Double {
        var delta = to - from
        if delta > 180 {
            delta -= 360
        }
        if delta < -180 {
            delta += 360
        }
        return delta
    }


    static func normalizedHue(_ hue: Double) -> Double {
        var output = hue.truncatingRemainder(dividingBy: 360)
        if output < 0 {
            output += 360
        }
        return output
    }


    static func oklab(from pixel: Pixel) -> (l: Double, a: Double, b: Double) {
        let r = linear(Double(pixel.r) / 255.0)
        let g = linear(Double(pixel.g) / 255.0)
        let b = linear(Double(pixel.b) / 255.0)

        let l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
        let m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
        let s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

        let lRoot = cubeRoot(l)
        let mRoot = cubeRoot(m)
        let sRoot = cubeRoot(s)

        return (
            0.2104542553 * lRoot + 0.7936177850 * mRoot - 0.0040720468 * sRoot,
            1.9779984951 * lRoot - 2.4285922050 * mRoot + 0.4505937099 * sRoot,
            0.0259040371 * lRoot + 0.7827717662 * mRoot - 0.8086757660 * sRoot
        )
    }


    static func pixelFromOKLab(l: Double, a: Double, b: Double) -> Pixel {
        let lRoot = l + 0.3963377774 * a + 0.2158037573 * b
        let mRoot = l - 0.1055613458 * a - 0.0638541728 * b
        let sRoot = l - 0.0894841775 * a - 1.2914855480 * b

        let lValue = lRoot * lRoot * lRoot
        let mValue = mRoot * mRoot * mRoot
        let sValue = sRoot * sRoot * sRoot

        let r = 4.0767416621 * lValue - 3.3077115913 * mValue + 0.2309699292 * sValue
        let g = -1.2684380046 * lValue + 2.6097574011 * mValue - 0.3413193965 * sValue
        let bValue = -0.0041960863 * lValue - 0.7034186147 * mValue + 1.7076147010 * sValue

        return Pixel(
            r: UInt8((clamp(encoded(r)) * 255).rounded()),
            g: UInt8((clamp(encoded(g)) * 255).rounded()),
            b: UInt8((clamp(encoded(bValue)) * 255).rounded())
        )
    }


    static func linear(_ value: Double) -> Double {
        if value <= 0.04045 {
            return value / 12.92
        }
        return pow((value + 0.055) / 1.055, 2.4)
    }


    static func encoded(_ value: Double) -> Double {
        if value <= 0.0031308 {
            return 12.92 * value
        }
        return 1.055 * pow(value, 1 / 2.4) - 0.055
    }


    static func cubeRoot(_ value: Double) -> Double {
        if value < 0 {
            return -pow(-value, 1.0 / 3.0)
        }
        return pow(value, 1.0 / 3.0)
    }


    static func clamp(_ value: Double) -> Double {
        return min(max(value, 0.0), 1.0)
    }


    static func apply(curve: ColourCurve, to pixel: Pixel) -> Pixel {
        let source = (
            r: Double(pixel.r) / 255.0,
            g: Double(pixel.g) / 255.0,
            b: Double(pixel.b) / 255.0
        )
        let luminance = 0.2126 * source.r + 0.7152 * source.g + 0.0722 * source.b
        let adjusted = (
            r: applyChannelCurve(
                value: luminance + (source.r - luminance) * curve.saturation,
                curve: curve
            ),
            g: applyChannelCurve(
                value: luminance + (source.g - luminance) * curve.saturation,
                curve: curve
            ),
            b: applyChannelCurve(
                value: luminance + (source.b - luminance) * curve.saturation,
                curve: curve
            )
        )
        return Pixel(
            r: UInt8((adjusted.r * 255).rounded()),
            g: UInt8((adjusted.g * 255).rounded()),
            b: UInt8((adjusted.b * 255).rounded())
        )
    }


    static func applyChannelCurve(value: Double, curve: ColourCurve) -> Double {
        let contrasted = (value - 0.5) * curve.contrast + 0.5
        let brightened = contrasted + curve.brightness
        let clamped = clamp(brightened)
        guard curve.gamma > 0 else {
            return clamped
        }
        return clamp(pow(clamped, 1.0 / curve.gamma))
    }
}
