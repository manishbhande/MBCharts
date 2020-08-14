//
//  ScaleFormatter.swift
//  SwiftUIDashboard
//
//  Created by Manish on 03/08/2020.
//  Copyright © 2020 Manish. All rights reserved.
//

import Foundation

struct ChartScaleFormatter {

    let maxValue: Double
    let minValue: Double
    let range: ClosedRange<Double>
    let interval: Double
    let noOfIntervals: Int

    init(min minV: Double = 0, max maxV: Double, noOfIntervals: Int) {
        self.minValue = minV
        self.maxValue = maxV
        self.noOfIntervals = noOfIntervals

        let tempInterval = maxV/Double(noOfIntervals)
        let d = ceil(log10(tempInterval < 0 ? -tempInterval : tempInterval))
        let pw = 1 - Int(d)
        let magnitude = pow(10.0, Double(pw))
        let shifted = (tempInterval * magnitude).rounded()
        interval = (shifted / magnitude)
        range = minV...max(interval*Double(noOfIntervals), maxV)
    }
}
