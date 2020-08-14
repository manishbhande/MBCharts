//
//  ChartValueLabel.swift
//  SwiftUIDashboard
//
//  Created by Manish on 01/08/2020.
//  Copyright © 2020 Manish. All rights reserved.
//

import SwiftUI

// MARK: - ValueStyle
struct ValueStyle: ChartStyle {

    var show = true
    var font: Font = .system(size: 10, weight: .light)
    var color: Color = .primary
    var format: (Double) -> String = { "\(Int($0))" }
    var padding: () -> (Edge.Set, CGFloat?) = { (.init(), nil) }
    var rotate: Angle = .zero
}

// MARK:- View
struct ChartValueLabel: View {

    private let style: ValueStyle
    private let title: String?

    init(value: Double, style: ValueStyle) {
        self.init(title: style.format(value), style: style)
    }

    init(title: String?, style: ValueStyle) {
        self.title = title
        self.style = style
    }

    var body: some View {

        if style.show, let str = title {
            Text(str)
                .multilineTextAlignment(.center)
                .font(style.font)
                .rotationEffect(style.rotate)
                .padding(style.padding)
                .foregroundColor(style.color)
        }
    }
}

struct ChartValueLabel_Previews: PreviewProvider {
    static var previews: some View {
        ChartValueLabel(title: "34", style: ValueStyle())
    }
}
