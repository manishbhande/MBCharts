//
//  LegendView.swift
//  SwiftUIDashboard
//
//  Created by Manish on 28/07/2020.
//  Copyright © 2020 Manish. All rights reserved.
//

import SwiftUI

// MARK: - LegendStyle
struct LegendStyle: ChartStyle {

    enum VAlignment {
        case leading, trailing, center
    }

    enum HAlignment {
        case top, bottom, center
    }

    enum Orientation {
        case vertical, horizontal
    }

    var verticalAlignment: VAlignment = .trailing
    var horizontalAlignment: HAlignment = .center
    var orientation: Orientation = .vertical
    var font: Font = .system(size: 10)
    var labelColor: Color = .primary
    var padding: () -> (Edge.Set, CGFloat?) = { (.init(), nil) }
}

// MARK:- View
struct ChartLegendView: View {

    let legends: [String]
    let colors: [Color]
    let style: LegendStyle

    init(legends: [String], colors: [Color], style: LegendStyle) {
        self.legends = legends
        self.style = style
        var lColors = colors
        // make color and legend equal
        if colors.count < legends.count {
            ((colors.count-1)..<legends.count).forEach{ _ in lColors.append(.clear) }
        }
        self.colors = lColors
    }

    var body: some View {
        VStack(spacing: 0) {

            switch style.orientation {
            case .vertical:
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(0..<legends.count, id: \.self) { idx in
                        legendLabel(at: idx)
                    }
                }

            case .horizontal:
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], alignment: .center, spacing: 4) {
                    ForEach(0..<legends.count, id: \.self) { idx in
                        legendLabel(at: idx)
                    }
                }
            }
        }.padding(style.padding)
    }

    private func legendLabel(at: Int) -> some View {
        HStack(alignment: .center, spacing: 4) {
            Rectangle().frame(width: 10, height: 10).foregroundColor(colors[at])
            Text(self.legends[at])
                .font(self.style.font)
                .foregroundColor(self.style.labelColor)
        }
    }

}


struct LegendView_Previews: PreviewProvider {

    static let titles = (1...5).map{ ("\($0) Lengend") }
    static let colors = (1...5).map{ _ in Color.random }
    static let chart = AnyView(Text("Chart").font(.title)
                                .frame(width: 100, height: 100).background(Color.random))


    static var previews: some View {

        let styles = [LegendStyle(verticalAlignment: .center, horizontalAlignment: .top, orientation: .horizontal),
                      LegendStyle(verticalAlignment: .leading, horizontalAlignment: .top),
                      LegendStyle(verticalAlignment: .leading, horizontalAlignment: .center),
                      LegendStyle(verticalAlignment: .leading, horizontalAlignment: .bottom),
                      LegendStyle(verticalAlignment: .trailing, horizontalAlignment: .top),
                      LegendStyle(verticalAlignment: .trailing, horizontalAlignment: .center),
                      LegendStyle(verticalAlignment: .trailing, horizontalAlignment: .bottom),
                      LegendStyle(verticalAlignment: .center, horizontalAlignment: .top),
                      LegendStyle(verticalAlignment: .center, horizontalAlignment: .center),
                      LegendStyle(verticalAlignment: .center, horizontalAlignment: .bottom)]
        Group {
            ForEach(0..<styles.count){ idx in
                ChartAlignment.align(chart: chart, legends: ChartLegendView(legends: titles, colors: colors, style: styles[idx]), style:  styles[idx])
            }.previewLayout(.sizeThatFits)
        }
    }
}
