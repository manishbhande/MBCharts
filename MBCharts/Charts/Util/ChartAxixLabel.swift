//
//  ChartAxixLabel.swift
//  SwiftUIDashboard
//
//  Created by Manish on 01/08/2020.
//  Copyright © 2020 Manish. All rights reserved.
//

import SwiftUI

// MARK: - AxisStyle
struct AxisStyle: ChartStyle {

    var show = true
    var font: Font = .system(size: 10)
    var color: Color = .primary
    var format: (Double) -> String = { "\(Int($0))" }
    var padding: () -> (Edge.Set, CGFloat?) = { (.init(), nil) }
    var rotate: Angle = .zero
}

// MARK: - View
struct ChartAxixLabel: View {
    
    let style: AxisStyle
    let title: String
    
    init(title: String, style: AxisStyle) {
        self.title = title
        self.style = style
    }
    
    init(value: Double, style: AxisStyle) {
        self.title = style.format(value)
        self.style = style
    }
    
    var body: some View {

        if style.show {
            Text(title)
                .font(style.font)
                .multilineTextAlignment(.center)
                .rotationEffect(style.rotate)
                .padding(style.padding)
                .foregroundColor(style.color)
        }
    }
}

struct ChartAxixLabel_Previews: PreviewProvider {
    
    static let style: AxisStyle = {
        var style = AxisStyle()
        style.rotate = .degrees(-45)
        return style
    }()
    
    static var previews: some View {
        HStack {
            VStack {
                Rectangle().foregroundColor(.random)
                ChartAxixLabel(title: "Axis 1", style: style)
            }
            VStack {
                Rectangle().foregroundColor(.random)
                ChartAxixLabel(title: "Axis 2", style: style)
            }
            VStack {
                Rectangle().foregroundColor(.random)
                ChartAxixLabel(title: "Axis 2", style: style)
            }
        }.frame(width: 150, height: 300)
    }
}
