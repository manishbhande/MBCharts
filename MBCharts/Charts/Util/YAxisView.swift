//
//  YAxisView.swift
//  SwiftUIDashboard
//
//  Created by Manish on 03/08/2020.
//  Copyright © 2020 Manish. All rights reserved.
//

import SwiftUI

struct YAxisView: View {

    let style: AxisStyle
    let scale: ChartScaleFormatter

    @State private var labelHeight: CGFloat?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                Color.clear
                let offsetY = (geometry.size.height/CGFloat(scale.range.upperBound)) * CGFloat(scale.interval)
                ForEach(Range(0...scale.noOfIntervals)) { id in
                    let newOffset = (offsetY *  CGFloat(id)) - (labelHeight ?? 0)/2
                    label(id: id)
                        .equalHeight($labelHeight)
                        .offset(x: 0, y: -newOffset)
                }
            }
        }
    }

    func label(id: Int) -> some View {
        let str = "\(Int(scale.interval) * id)"
        return ChartAxixLabel(title: str, style: style)
    }
}

struct YAxisView_Previews: PreviewProvider {
    static var previews: some View {
        YAxisView(style: BarChartStyle().yAxis,
                  scale: ChartScaleFormatter(max: 100, noOfIntervals: 5))
    }
}
