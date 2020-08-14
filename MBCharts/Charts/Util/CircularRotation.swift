//
//  CircularRotation.swift
//  SwiftUIDashboard
//
//  Created by Manish on 08/08/2020.
//  Copyright © 2020 Manish. All rights reserved.
//

import SwiftUI

struct CircularRotation: ViewModifier {

    init(_ rotation: Binding<Angle>) {
        self._rotation = rotation
    }

    @Binding var rotation: Angle
    @State private var prevDelta: Angle = .zero

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .rotationEffect(rotation)
                .gesture(circularGesture(center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)))
        }
    }

    private func circularGesture(center: CGPoint) -> some Gesture {
        DragGesture()
            .onChanged { value in
                //Calculate the angle from the center of the view to the previous touch point.
                let previousAngle = atan2(Double(value.startLocation.y - center.y),
                                          Double(value.startLocation.x - center.x))
                //Calculate the angle from the center of the view to the current touch point.
                let currentAngle = atan2(Double(value.location.y - center.y),
                                         Double(value.location.x - center.x))
                rotation = .init(radians:(currentAngle - previousAngle)) + prevDelta
            }.onEnded { _ in
                prevDelta = rotation
            }
    }

}

struct CircularRotation_Previews: PreviewProvider {
    static var previews: some View {

        Rectangle().frame(width: 300, height: 300)
            .modifier(CircularRotation(.constant(.degrees(0))))
    }
}
