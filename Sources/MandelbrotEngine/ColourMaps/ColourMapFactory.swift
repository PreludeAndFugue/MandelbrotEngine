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
            mapping: .smoothEscape
        )
    }
}
