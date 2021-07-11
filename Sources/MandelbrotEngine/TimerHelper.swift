//
//  TimerHelper.swift
//  MandelbrotApp
//
//  Created by gary on 13/06/2021.
//  Copyright © 2021 Gary Kerr. All rights reserved.
//


import Foundation

public struct Timer {
    public typealias Action = (TimeInterval) -> Void

    private let nano = 1_000_000_000.0
    let start: DispatchTime
    let action: Action


    init(action: @escaping Action) {
        self.action = action
        self.start = DispatchTime.now()
    }


    func end() {
        let e = DispatchTime.now()
        let dt = e.uptimeNanoseconds - start.uptimeNanoseconds
        let s = Double(dt) / nano
        action(s)
    }
}
