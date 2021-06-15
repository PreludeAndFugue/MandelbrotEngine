//
//  TimerHelper.swift
//  MandelbrotApp
//
//  Created by gary on 13/06/2021.
//  Copyright © 2021 Gary Kerr. All rights reserved.
//


import Foundation

struct TimerHelper {
    private let nano = 1_000_000_000.0
    let start: DispatchTime

    init() {
        self.start = DispatchTime.now()
    }


    func end() {
        let e = DispatchTime.now()
        let dt = e.uptimeNanoseconds - start.uptimeNanoseconds
        print(Double(dt) / nano)
    }
}
