//
//  ProgressHelper.swift
//  MandelbrotApp
//
//  Created by gary on 13/06/2021.
//  Copyright © 2021 Gary Kerr. All rights reserved.
//

import Foundation

struct ProgressHelper {
    let countFraction: Double
    let progress: Progress


    init(steps: Int, progress: Progress) {
        self.countFraction = Double(100) / Double(steps)
        self.progress = progress
    }


    func update(step: Int) {
        let completedUnitCount = Int64(countFraction * Double(step))
        DispatchQueue.main.async {
            progress.completedUnitCount = completedUnitCount
        }
    }
}
