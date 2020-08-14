//
//  BarChartView.swift
//  SwiftUIDashboard
//
//  Created by Manish on 31/07/2020.
//  Copyright © 2020 Manish. All rights reserved.
//

import SwiftUI

// MARK: - Chart Style
/// Subclass for custom style
struct BarChartStyle: ChartStyle {

    var legends: LegendStyle = LegendStyle(horizontalAlignment: .top,
                                           orientation: .horizontal,
                                           padding: { (.bottom, 5) })

    var value: ValueStyle = ValueStyle(padding: { (.bottom, 3) })
    var title: TitleStyle = TitleStyle(font: .headline, padding: {(.all, 5)} )
    var barWidth: CGFloat = 1 //0...1
    var barSpacing: CGFloat = 5 // Space between gruop bar
    var spacing: CGFloat = 10
    var barCornerRadius: CGFloat = 2
    var xAxis: AxisStyle = AxisStyle(padding: {(.top, 15) }, rotate: .degrees(-35))
    var yAxis: AxisStyle = AxisStyle(padding: {(.trailing, 5) })
}

// MARK:- View
struct BarChartView: View {

    fileprivate let style: BarChartStyle
    let data: [BarChartData]?
    fileprivate let onSelection: BarChart.ChartAction?

    init(data: [BarChartData]?, onSelection: BarChart.ChartAction? = nil) {
        self.init(data: data, style: BarChartStyle(), onSelection: onSelection)
    }

    fileprivate init(data: [BarChartData]?, style: BarChartStyle, onSelection: BarChart.ChartAction? = nil) {
        self.data = data
        self.onSelection = onSelection
        self.style = style
    }

    var body: some View {

        VStack {
            if data == nil {
                Text("No chart data avilable.")
            } else {

                VStack(spacing: 0) {
                    ChartTitleLabel(title: data?.first?.title, style: style.title)
                    ChartAlignment.align(chart: BarChart(data: data!, style: BarChartStyle(), onSelection: onSelection),
                                         legends: legends,
                                         style: style.legends)
                }
            }
        }
    }

    var legends: some View {
        let legends = data?.compactMap { $0.legend } ?? []
        let colors = data?.map { item -> [Color] in
            var pointColors = item.colors ?? []
            if let color = item.color {
                pointColors.append(color)
            }
            return pointColors
        }.reduce([], +)

        return ChartLegendView(legends: legends, colors: colors ?? [], style: style.legends)
    }

}

extension BarChartView {

    func style(_ style: BarChartStyle) -> some View {
        BarChartView.init(data: data, style: style, onSelection: onSelection)
    }
}

// MARK:- Actual bar chart
struct BarChart: View {

    typealias ChartAction = ((_ id: ChartDataID?, _ point: BarChartPoint) -> Void)

    private let style: BarChartStyle
    private let data: [BarChartData]
    private let yAxisScale: ChartScaleFormatter
    private let xCount: Int
    private let xAxisTitles: [String]
    private var onSelection: ChartAction?

    @State private var xAxisLabelHeight: CGFloat?
    @State private var valueLabelHeight: CGFloat?
    @State private var shouldAnimate = false

    init(data: [BarChartData], style: BarChartStyle, onSelection: ChartAction?) {
        self.style = style
        self.data = data
        self.onSelection = onSelection
        self.xCount = Int(data.map { $0.points.maxX }.max() ?? 0)
        self.xAxisTitles = data.max { $0.xAxisTitle.count < $1.xAxisTitle.count }?.xAxisTitle ?? []

        let maxValue = data.map { $0.points.maxY }.max() ?? 0
        yAxisScale = ChartScaleFormatter(min: 0, max: maxValue, noOfIntervals: 5)
    }

    var body: some View {

        ZStack(alignment: .leading) {

            YAxisView(style: style.yAxis, scale: yAxisScale)
                .padding(.bottom, xAxisLabelHeight)
                .padding(.top, valueLabelHeight)
                .frame(width: 30)

            HStack(spacing: 0) {

                ForEach(0...xCount, id: \.self) { idx in

                    VStack(spacing: 0) {

                        // draw for each group
                        HStack(spacing: 0) {
                            Divider()
                            HStack(spacing: style.barSpacing) {
                                ForEach(0..<data.count, id:\.self) { grpIdx in
                                    let group = data[grpIdx]
                                    if let point = group.pointsXDict[idx] {
                                        barView(point: point, color: group.color)
                                            .onTapGesture {
                                                onSelection?(group.id, point)
                                            }
                                    } else {
                                        emptyBar()
                                    }
                                }
                            }
                            .padding(.horizontal, style.spacing)
                            Divider().hidden()
                        }
                        // Axix
                        Divider()
                        xAxisAt(idx: idx)
                            .padding(.horizontal, style.spacing)
                    }
                }

            }
            .onAppear {
                withAnimation(.spring()) {
                    shouldAnimate = true
                }
            }
            .padding(.leading, 30)
        }

    }

    private func xAxisAt(idx: Int) -> some View {

        VStack(spacing: 0) {

            if xAxisTitles.count > idx {
                ChartAxixLabel(title: xAxisTitles[idx], style: style.xAxis)
                    .equalHeight($xAxisLabelHeight)

            } else {
                emptyBar()
                    .equalHeight($xAxisLabelHeight)
            }
        }
    }

    private func emptyBar() -> some View {
        Rectangle().scaleEffect(x: 0, y: 0, anchor: .bottom)
    }

    private func barView(point: BarChartPoint, color: Color?) -> some View {

        GeometryReader { reader in

            let barHeight: CGFloat = shouldAnimate
                ? ((reader.size.height - (valueLabelHeight ?? 0))
                    / CGFloat(yAxisScale.range.upperBound)) * CGFloat(point.y)
                : 0

            ZStack(alignment: .bottom) {

                ChartValueLabel(value: point.y, style: style.value)
                    .equalHeight($valueLabelHeight)
                    .offset(x: 0, y: -barHeight)
                    .zIndex(2)

                RoundedRectangle(cornerRadius: style.barCornerRadius)
                    .padding(.top, reader.size.height - barHeight)
                    .scaleEffect(x: style.barWidth, y: 1, anchor: .center)
                    .foregroundColor(point.color ?? color)
            }
        }
    }
}


struct BarChartView_Previews: PreviewProvider {

    static func points(count: Int, color: Color? = nil) -> [BarChartPoint] {
        (0..<count).map {
            BarChartPoint(x: $0, y: Double(Int.random(in: 0...120)), label: "\($0) Label", color: color)
        }
    }

    struct Test: View {

        @State var data = BarChartData(points: BarChartView_Previews.points(count: 4), color: .red, legend: "Legend 1")

        var body: some View {
            VStack {
                Button("Tap") {
                    withAnimation(.spring()) {
                        data = BarChartData(points: BarChartView_Previews.points(count:  Int.random(in: 3...6)),
                                            color: .random, legend: "Legend 1")
                    }
                }
                BarChartView(data: [data])
            }
        }

    }


    static var previews: some View {

        let data1 = BarChartData(points: Self.points(count: 4), color: .red, legend: "Legend 1", title: "This is group bar chart")
        let data2 = BarChartData(points: Self.points(count: 4), color: .green, legend: "Legend 2")

        VStack(spacing: 20) {

            Test()
                .padding(.all, 15)
                .background(Color(white: 0.95))
                .frame(width: 300)

            ScrollView(.horizontal) {
                BarChartView(data: [data1,data2])
                    .padding(.all, 10)
                    .background(Color(white: 0.95))
                    .frame(width: 400)
            }
        }

    }
}
