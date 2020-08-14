//
//  ChartTitleLabel.swift
//  SwiftUIDashboard
//
//  Created by Manish on 08/08/2020.
//  Copyright © 2020 Manish. All rights reserved.
//

import SwiftUI

//MARK:- TitleStyle
struct TitleStyle: ChartStyle {

    var show = true
    var font: Font = .caption
    var padding: () -> (Edge.Set, CGFloat?) = { (.init(), nil) }
    var color: Color? = nil
}

// MARK:- View
struct ChartTitleLabel: View {

    let title: String?
    let style: TitleStyle

    var body: some View {
        if style.show, let str = title {
            Text(str)
                .font(style.font)
                .padding(style.padding)
                .foregroundColor(style.color)
        }
    }
}

struct ChartTitleLabel_Previews: PreviewProvider {
    static var previews: some View {
        ChartTitleLabel(title: "Chart title", style: TitleStyle())
    }
}
