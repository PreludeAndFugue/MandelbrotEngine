//
//  ColourMapFactory.swift
//  MandelbrotApp
//
//  Created by gary on 13/09/2018.
//  Copyright © 2018 Gary Kerr. All rights reserved.
//

public struct ColourMapFactory {
    public static var maps: [ColourMapProtocol] {
        return [
            GreyScale(numberOfGreys: 200),
            YellowScale(numberOfYellows: 100),
            SmoothScale(),
            deepSmoothGradient,
            solarSmoothGradient,
            iceSmoothGradient,
            warmRGBGradient,
            spectrumHSVGradient,
            perceptualOKLabGradient,
            smoothEscapeGradient,
            APIMandelbrotSet(),
            SmoothTest()
        ]
    }
}


// MARK: - Private

private extension ColourMapFactory {
    static var deepSmoothGradient: ColourMapProtocol {
        let palette = ColourPalette(
            name: "Deep Smooth",
            stops: [
                ColourStop(position: 0.0, rgb: (r: 1, g: 5, b: 22)),
                ColourStop(position: 0.28, rgb: (r: 12, g: 48, b: 120)),
                ColourStop(position: 0.48, rgb: (r: 37, g: 174, b: 212)),
                ColourStop(position: 0.68, rgb: (r: 255, g: 244, b: 181)),
                ColourStop(position: 0.82, rgb: (r: 242, g: 161, b: 39)),
                ColourStop(position: 1.0, rgb: (r: 255, g: 255, b: 255))
            ],
            interpolation: .oklab
        )
        return try! GradientColourMap(
            palette: palette,
            sampleCount: 1024,
            mapping: .smoothEscape,
            curve: ColourCurve(contrast: 1.08, gamma: 1.04, saturation: 1.05),
            ditherStrength: 0.2,
            escapePeriod: 48
        )
    }


    static var solarSmoothGradient: ColourMapProtocol {
        let palette = ColourPalette(
            name: "Solar Smooth",
            stops: [
                ColourStop(position: 0.0, rgb: (r: 5, g: 7, b: 24)),
                ColourStop(position: 0.24, rgb: (r: 94, g: 20, b: 53)),
                ColourStop(position: 0.45, rgb: (r: 213, g: 71, b: 31)),
                ColourStop(position: 0.68, rgb: (r: 255, g: 195, b: 63)),
                ColourStop(position: 0.86, rgb: (r: 255, g: 243, b: 193)),
                ColourStop(position: 1.0, rgb: (r: 255, g: 255, b: 255))
            ],
            interpolation: .oklab
        )
        return try! GradientColourMap(
            palette: palette,
            sampleCount: 1024,
            mapping: .smoothEscape,
            curve: ColourCurve(contrast: 1.06, gamma: 1.03, saturation: 1.08),
            ditherStrength: 0.18,
            escapePeriod: 44
        )
    }


    static var iceSmoothGradient: ColourMapProtocol {
        let palette = ColourPalette(
            name: "Ice Smooth",
            stops: [
                ColourStop(position: 0.0, rgb: (r: 2, g: 10, b: 38)),
                ColourStop(position: 0.32, rgb: (r: 18, g: 64, b: 154)),
                ColourStop(position: 0.55, rgb: (r: 62, g: 181, b: 220)),
                ColourStop(position: 0.78, rgb: (r: 204, g: 249, b: 255)),
                ColourStop(position: 1.0, rgb: (r: 255, g: 255, b: 255))
            ],
            interpolation: .oklab
        )
        return try! GradientColourMap(
            palette: palette,
            sampleCount: 1024,
            mapping: .smoothEscape,
            curve: ColourCurve(contrast: 1.05, gamma: 1.06, saturation: 1.03),
            ditherStrength: 0.15,
            escapePeriod: 52
        )
    }


    static var warmRGBGradient: ColourMapProtocol {
        return try! GradientColourMap(
            title: "Warm RGB gradient",
            colourStops: [
                (r: 255, g: 0, b: 0),
                (r: 255, g: 255, b: 0),
                (r: 255, g: 255, b: 255)
            ],
            stepsPerSegment: 100
        )
    }


    static var spectrumHSVGradient: ColourMapProtocol {
        let palette = ColourPalette(
            name: "Spectrum HSV gradient",
            stops: [
                ColourStop(position: 0.0, rgb: (r: 255, g: 0, b: 0)),
                ColourStop(position: 0.2, rgb: (r: 255, g: 255, b: 0)),
                ColourStop(position: 0.4, rgb: (r: 0, g: 255, b: 0)),
                ColourStop(position: 0.6, rgb: (r: 0, g: 255, b: 255)),
                ColourStop(position: 0.8, rgb: (r: 0, g: 0, b: 255)),
                ColourStop(position: 1.0, rgb: (r: 255, g: 0, b: 255))
            ],
            interpolation: .hsv
        )
        return try! GradientColourMap(palette: palette, sampleCount: 512)
    }


    static var perceptualOKLabGradient: ColourMapProtocol {
        let palette = ColourPalette(
            name: "Perceptual OKLab gradient",
            stops: [
                ColourStop(position: 0.0, rgb: (r: 4, g: 7, b: 38)),
                ColourStop(position: 0.25, rgb: (r: 33, g: 122, b: 184)),
                ColourStop(position: 0.55, rgb: (r: 255, g: 241, b: 118)),
                ColourStop(position: 0.8, rgb: (r: 224, g: 80, b: 35)),
                ColourStop(position: 1.0, rgb: (r: 255, g: 255, b: 255))
            ],
            interpolation: .oklab
        )
        return try! GradientColourMap(palette: palette, sampleCount: 512)
    }


    static var smoothEscapeGradient: ColourMapProtocol {
        let palette = ColourPalette(
            name: "Smooth escape gradient",
            stops: [
                ColourStop(position: 0.0, rgb: (r: 0, g: 7, b: 30)),
                ColourStop(position: 0.35, rgb: (r: 32, g: 107, b: 203)),
                ColourStop(position: 0.65, rgb: (r: 255, g: 224, b: 86)),
                ColourStop(position: 1.0, rgb: (r: 255, g: 255, b: 255))
            ],
            interpolation: .oklab
        )
        return try! GradientColourMap(
            palette: palette,
            sampleCount: 768,
            mapping: .smoothEscape,
            curve: ColourCurve(contrast: 1.05, gamma: 1.03, saturation: 1.05),
            ditherStrength: 0.15,
            escapePeriod: 48
        )
    }
}
