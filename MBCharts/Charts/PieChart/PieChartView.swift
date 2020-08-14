//
//  PieChart.swift
//  SwiftUIDashboard
//
//  Created by Manish on 27/07/2020.
//  Copyright © 2020 Manish. All rights reserved.
//

import SwiftUI
import CoreGraphics

// MARK: - Chart Style
struct PieChartStyle: ChartStyle {

    var legends: LegendStyle = LegendStyle()
    var value: ValueStyle = ValueStyle()
    var startAngle: Double = 0 //0...360
    var rotationAngle: Double = 360//0...360
    var padding: Double = 1//0...360
    var innerShield: CGFloat = 0.48 // 0...1 // must be less than 'depth'
    var depth: CGFloat = 0.53// 0...1
    var title: TitleStyle = TitleStyle()

    static func halfPieChart(start: Double, rotation: Double) -> Self {
        var style = PieChartStyle()
        style.startAngle = start
        style.rotationAngle = rotation
        style.legends.orientation = .horizontal
        style.legends.horizontalAlignment = .top
        style.legends.verticalAlignment = .center
        style.title.padding = { (.bottom, 20) }
       // style.value.font = .caption
        return style
    }
}

// MARK:- PieChartView
struct PieChartView: View {

    fileprivate let style: PieChartStyle
    let data: PieChartData?
    fileprivate let onSelection: PieChart.ChartAction?

    init(data: PieChartData?, onSelection: PieChart.ChartAction? = nil) {
        self.init(data: data, style: PieChartStyle(), onSelection: onSelection)
    }

    init(data: PieChartData?, style: PieChartStyle, onSelection:  PieChart.ChartAction? = nil) {
        self.data = data
        self.onSelection = onSelection
        self.style = style
    }

    var body: some View {
        VStack {
            if data == nil {
                Text("No chart data avilable.")
            } else {
                ChartAlignment.align(chart: pieChart, legends: legends,  style: style.legends)
            }
        }
    }

    var legends: some View {
        ChartLegendView(legends: data!.legends, colors: data!.colors ?? [], style: style.legends)
    }

    private var pieChart: some View {

        GeometryReader { reader in

            PieChart(style: style, data: data!, size: reader.size, onSelection: onSelection)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: Apply style
extension PieChartView {

    func style(_ style: PieChartStyle) -> PieChartView {
        PieChartView.init(data: data, style: style, onSelection: onSelection)
    }
}


// MARK: - Actual Pie chart
struct PieChart: View {

    struct PieArcData {

        let start: Angle
        let delta: Angle
        let color: Color
        let point: PieChartPoint
        let radius: Double
    }

    typealias ChartAction = (_ id: ChartDataID?, _ point: PieChartPoint) -> Void

    private var arcs: [PieArcData] = []
    private var onSelection: ChartAction?
    private let size: CGSize
    private let style: PieChartStyle
    private let dataId: ChartDataID?
    private let title: String
    init(style: PieChartStyle, data: PieChartData, size: CGSize, onSelection: ChartAction? = nil) {

        self.style = style
        self.dataId = data.id
        self.onSelection = onSelection
        self.size = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        self.title = data.title ?? ""
        let height = self.size.height
        let lineWidth = height/2 * CGFloat(1-style.depth)
        let radius = height/2 - lineWidth/2
        let dataCount = Double(data.points.count-(style.rotationAngle < 360 ? 1 : 0))
        let avilableRotation: Double = style.rotationAngle - (dataCount*style.padding)
        let sum = data.total

        var start: Double = style.startAngle
        arcs = data.points
            .map { point -> PieArcData in
                let delta = avilableRotation * (point.value/sum)
                  let arc = PieArcData(start: Angle.degrees(Double(start)),
                                     delta: Angle.degrees(Double(delta)),
                                     color: point.color,
                                     point: point,
                                     radius: Double(radius))
                start += (delta+style.padding)
                return arc
            }
    }

    @State private var showData = false
    @State private var circularRotation: Angle = .zero

    var body: some View {

        ZStack {
            // PieArc
            arcsView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .modifier(CircularRotation($circularRotation))

            // Values
            arcValuesView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .overlay(Text(title).font(style.title.font).padding(style.title.padding))
        .frame(width: size.width, height: size.height)
        .onAppear {
            withAnimation(Animation.linear(duration: 0.5)) {
                showData = true
            }
        }

    }

    @State private var selectedIndex: Int?

    private var arcsView: some View {

        ZStack {
            ForEach(0..<arcs.count, id: \.self) { idx in
                let arc = self.arcs[idx]
                let start = showData ? arc.start : .zero
                let delta = showData ? arc.delta : .zero

                // Draw inner arc
                PieArc(start: start, delta: delta, depth: style.innerShield)
                    .foregroundColor(arc.color.opacity(0.5))

                PieArc(start: start, delta: delta, depth: style.depth)
                    .foregroundColor(arc.color)
                    .onTapGesture {
                        selectedIndex = selectedIndex == idx ? nil : idx
                        self.onSelection?(dataId, arc.point)
                    }
                    .modifier(SubPieChart(data: arc, isSelected: idx == selectedIndex, rotationOffset: $circularRotation))

            }
        }
    }

    private var arcValuesView: some View {
        ZStack {
            ForEach(0..<arcs.count, id: \.self) { idx in
                let arc = self.arcs[idx]
                let offset = showData ? CGPoint.betweenAngles(start: arc.start + circularRotation,
                                                              delta: arc.delta, radius: arc.radius)
                    : .zero
               // ChartValueLabel(value: arc.point.value, style: style.value)
                Text("\(Int(arc.point.value))").font(.caption).padding()
                    .offset(x: offset.x, y: offset.y)
                    .zIndex(3)
            }
        }
    }
}

// MARK: - SubPieChart
struct SubPieChart: ViewModifier {

    let data: PieChart.PieArcData
    let isSelected: Bool
    @Binding var rotationOffset: Angle

    func body(content: Content) -> some View {

        let subPieData = subPieArcs

        return ZStack {
            content
            ZStack {
            ForEach(0..<subPieData.count, id: \.self) { idx in
                let arc = subPieData[idx]
                // Arc
                PieArc(start: arc.start, delta: arc.delta,
                       depth: isSelected ? 1.3 : 1)
                    .foregroundColor(arc.color)
                    .animation(Animation.spring().delay(Double(idx)*0.1))
                  //  .rotationEffect(rotationOffset)

                // Value
                //  if isSelected {
                let offset = isSelected
                    ? CGPoint.betweenAngles(start: arc.start, delta: arc.delta, radius: 140)
                    : CGPoint.betweenAngles(start: arc.start, delta: arc.delta, radius: 120)

                //ChartValueLabel(value: arc.point.value, style: ValueStyle())
                Text("\(Int(arc.point.value))").font(.caption2).padding()
                    .offset(x: offset.x, y: offset.y)
                    .zIndex(1)
                    .opacity(isSelected ? 1: 0)
                    .animation(Animation.spring().delay(Double(idx)*0.1))
                //  }
            }
            }

        }
    }

    private var subPieArcs: [PieChart.PieArcData] {

        guard let subPoints = data.point.subPoints, subPoints.count > 0
        else { return [] }

        let sum = subPoints.sumValues
        var start = data.start.degrees

        return subPoints.map { each -> PieChart.PieArcData in
            let delta = data.delta.degrees * (each.value/sum)
            let arc = PieChart.PieArcData(start: .degrees(start), delta: .degrees(delta), color: each.color, point: each, radius: 4)
            start += delta
            return arc
        }
    }
}

// MARK: - Arc shape
struct PieArc: Shape {

    var start: Angle
    var delta: Angle
    var depth: CGFloat //0...1

    func path(in rect: CGRect) -> Path {
        Path { path in

            let center = CGPoint(x: rect.midX, y: rect.midY)
            let r1: CGFloat = rect.midY * (depth)
            let r2: CGFloat = rect.midY
            path.addRelativeArc(center: center, radius: r1, startAngle: start, delta: delta)
            path.addRelativeArc(center: center, radius: r2, startAngle: start+delta, delta: -delta)
            path.closeSubpath()
        }
    }

    var animatableData: AnimatablePair<CGFloat, AnimatablePair<Double, Double>> {
        get {
            AnimatablePair(depth, AnimatablePair(start.degrees, delta.degrees))
        } set {
            self.depth = newValue.first
            self.start = .degrees(newValue.second.first)
            self.delta = .degrees(newValue.second.second)
        }
    }
}


// MARK: - Preview
struct PieChart_Previews: PreviewProvider {

    struct Test: View {

        @State var data: PieChartData? //= PieChartData.defaultData(count: Int.random(in: 4...6))

        var body: some View {
            VStack {
                Spacer()
                if let data = data {
                    PieChart(style: PieChartStyle(), data: data, size: CGSize(width: 250, height: 250))
                }
                Spacer()
                Button("Shuffle") {
                    withAnimation(Animation.linear(duration: 0.5)) {
                        data = PieChartData.defaultData(count: Int.random(in: 4...6))
                    }
                }

            }
        }
    }

    static var previews: some View {
        VStack {
            Test()
//                        PieChartView(data: PieChartData.defaultData)
//                            .style(.halfPieChart(start: 180, rotation: 180))
        }.padding()

    }
}

