//
//  BarChartData.swift
//  SwiftUIDashboard
//
//  Created by Manish on 13/08/2020.
//  Copyright © 2020 Manish. All rights reserved.
//

import Foundation
import SwiftUI

struct BarChartData: ChartData {

    var id: ChartDataID?
    var points: [BarChartPoint]
    var color: Color?
    var xAxis: [String]
    var legend: String?
    var title: String?

    var colors: [Color]? {
        let clrs = points.compactMap { $0.color }
        return clrs.count > 0 ? clrs : nil
    }

    var pointsXDict: [Int: BarChartPoint] {
        Dictionary(grouping: points) { $0.x }
            .mapValues{ $0.first! }
    }

    var xAxisTitle: [String] {
        let titles = points.compactMap { $0.label }
        return titles.count > 0 ? titles: xAxis
    }

    init(id: ChartDataID? = nil, points: [BarChartPoint] = [], color: Color? = nil, xAxis: [String] = [], legend: String? = nil, title: String? = nil) {
        self.id = id
        self.points = points
        self.color = color
        self.xAxis = xAxis
        self.legend = legend
        self.title = title
    }
}

// MARK:- chart Point
struct BarChartPoint: ChartPoint {

    var id: ChartDataID?
    let x: Int
    let y: Double
    let label: String?
    let color: Color?

    init(x: Int, y: Double, label: String? = nil, color: Color? = nil, id: ChartDataID? = nil) {
        self.x = x
        self.y = y
        self.label = label
        self.id = id
        self.color = color
    }

    init(x: Int, y: Int, label: String? = nil, color: Color? = nil, id: ChartDataID? = nil) {
        self.init(x: x, y: Double(y), label: label, color: color, id: id)
    }

}

// MARK:- Collection for point sum
extension Collection where Element == BarChartPoint {

    var sumY: Double {
        reduce(0) { $0 + $1.y }
    }

    var maxY: Double {
        self.max { $0.y < $1.y }?.y ?? 0
    }

    var maxX: Int {
        self.max { $0.x < $1.x }?.x ?? 0
    }
}

#if DEBUG
extension BarChartData {

    static var defaultData: BarChartData {
        let points = (0...5).compactMap { idx -> BarChartPoint? in
            if idx == 3 { return nil }
            return BarChartPoint(x: idx, y: Double.random(in: 0...100),label: "\(idx) title")
        }
        return BarChartData(points: points, color: .random)
    }
}
#endif
