//
//  PieChartData.swift
//  SwiftUIDashboard
//
//  Created by Manish on 13/08/2020.
//  Copyright © 2020 Manish. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Data
struct PieChartData: ChartData {

    var id: ChartDataID?
    var points: [PieChartPoint]
    var title: String?

    var legends: [String] {
        points.compactMap { $0.label }
    }

    var colors: [Color]? {
        let clrs = points.compactMap { $0.color }
        return clrs.count > 0 ? clrs: nil
    }

    var total: Double {
        points.sumValues
    }

    init(id: ChartDataID? = nil, points: [PieChartPoint] = [], title: String? = nil) {
        self.points = points
        self.title = title
        self.id = id
    }

}

// MARK: - PieChartPoint
struct PieChartPoint: ChartPoint {

    var id: ChartDataID?
    let value: Double
    let color: Color
    let label: String?
    var subPoints: [PieChartPoint]? = nil

    init<V>(value: V, color: Color, label: String? = nil, id: ChartDataID? = nil) where V: BinaryFloatingPoint {
        self.id = id
        self.value = Double(value)
        self.color = color
        self.label = label
    }

    init<V>(value: V, color: Color, label: String? = nil, id: ChartDataID? = nil) where V: BinaryInteger {
        self.init(value: Double(value), color: color, label: label, id: id)
    }

}

// MARK:- PieChartPoint Util
extension Collection where Element == PieChartPoint {

    var sumValues: Double {
        reduce(0){ $0 + $1.value }
    }
}

//MARK: - Helper
#if DEBUG
extension PieChartData {

    static var defaultData: PieChartData {
        defaultData(count: 6)
    }

    static func defaultData(count: Int) -> PieChartData {

        let clr = [Color(#colorLiteral(red: 0.6980392157, green: 0.5529411765, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.7952190042, green: 0.9433271289, blue: 0.3183194399, alpha: 1)), Color(#colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)), Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)), Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)), Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)), Color(#colorLiteral(red: 0.9114216566, green: 0.4414127469, blue: 1, alpha: 1))].shuffled()

        let points = (0..<count).map { idx -> PieChartPoint in


            let color = clr[idx]
//                Color(red: Double.random(in: 0.5...1),
//                              green: Double.random(in: 0.5...1),
//                              blue: Double.random(in: 0.5...1))

            let subPoints = (1...Int.random(in: 2...4)).map { idx -> PieChartPoint in

                PieChartPoint(value: Double.random(in: 40...60),
                              color: color.opacity(Double(idx)*0.2),
                                     label: "\(idx) Legend")
            }

            var point = PieChartPoint(value: subPoints.sumValues,
                                 color: color,
                                 label: "\(idx) Legend")
            point.subPoints = subPoints
            return point
        }

        return PieChartData(points: points, title: "\(Int(points.sumValues))")
    }


}
#endif
