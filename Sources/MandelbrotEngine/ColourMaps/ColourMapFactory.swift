//
//  ColourMapFactory.swift
//  MandelbrotApp
//
//  Created by gary on 13/09/2018.
//  Copyright © 2018 Gary Kerr. All rights reserved.
//

struct ColourMapFactory {
    static var maps: [ColourMapProtocol] {
        return [
            GreyScale(numberOfGreys: 200),
            YellowScale(numberOfYellows: 100),
            SmoothScale(),
            ManyColourGradient(
                n: 100,
                colours: (r: 255, g: 0, b: 0), (r: 255, g: 255, b: 0)
            ),
            ManyColourGradient(
                n: 70,
                colours: (r: 255, g: 0, b: 0), (r: 255, g: 255, b: 0), (r: 255, g: 255, b: 255)
            ),
            SmoothTest()
        ]
    }
}
