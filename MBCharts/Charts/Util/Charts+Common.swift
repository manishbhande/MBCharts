//
//  Charts+Common.swift
//  MBCharts
//
//  Created by Manish on 14/08/2020.
//

import Foundation
import SwiftUI

// MARK: - Utils
public extension CGPoint {

    static func betweenAngles(start: Angle, end: Angle, radius: Double) -> CGPoint {
        betweenAngles(start: start, delta: end-start, radius: radius)
    }

    static func betweenAngles(start: Angle, delta: Angle, radius: Double) -> CGPoint {
        fromAngle(start + delta/2, radius: radius)
    }

    static func fromAngle(_ theta: Angle, radius: Double) -> CGPoint {
        let x = cos(theta.radians) * radius
        let y = sin(theta.radians) * radius
        return CGPoint(x: x, y: y)
    }
}

// MARK:- Angle
extension Angle {

    static func between(point1: CGPoint, point2: CGPoint, center: CGPoint) -> Angle {

        .zero
    }
}

extension Color {

    static func random(within range: ClosedRange<Double>) -> Color {
        Color(red: Double.random(in: range), green: Double.random(in: range), blue: Double.random(in: range))
    }

    static var random: Color {
        random(within: 0...1)
    }
}
