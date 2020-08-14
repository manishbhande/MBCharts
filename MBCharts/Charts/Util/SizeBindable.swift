//
//  SizeBindable.swift
//  SwiftUIDashboard
//
//  Created by Manish on 01/08/2020.
//  Copyright © 2020 Manish. All rights reserved.
//

import SwiftUI

extension View {

    func equalWidth(_ width: Binding<CGFloat?>) -> some View  {
        modifier(WidthBindable(width: width))
            .frame(width: width.wrappedValue)
    }

    func equalHeight(_ height: Binding<CGFloat?>) -> some View  {
        modifier(HeightBindable(height: height))
            .frame(height: height.wrappedValue)
    }

    func padding(_ block: () -> (Edge.Set, CGFloat?)) -> some View {
        let newPadding = block()
        return self.padding(newPadding.0, newPadding.1)
    }
}

struct SizeBindable_Previews: PreviewProvider {

    struct Test: View {

        @State var size1: CGSize?
        @State var size2: CGSize?

        @State var w1: CGFloat?
        @State var w2: CGFloat?

        @State var h1: CGFloat?
        @State var h2: CGFloat?



        var body: some View {
            VStack(spacing: 10) {

                Text("Checking string sizes")
                    .equalWidth($w1)
                    .background(Color.red)
                Text("Checking other")
                    .equalWidth($w1)
                    .background(Color.red)

                Text("This for other check")
                    .equalHeight($h2)
                    .background(Color.green)
                Text("One more string to check size")
                    .equalHeight($h2)
                    .background(Color.green)
            }.padding()
        }

    }

    static var previews: some View {
        Test()
    }
}


// MARK:- PreferenceKey

struct WidthPreference: PreferenceKey {

    static var defaultValue: [CGFloat] { [] }
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

struct HeightPreference: PreferenceKey {

    static var defaultValue: [CGFloat] { [] }
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

struct WidthBindable: ViewModifier {

    typealias Preference = WidthPreference

    @Binding var width: CGFloat?

    func body(content: Content) -> some View {

        content
            .overlay(
                GeometryReader { geometry in
                    Color.clear.preference(key: Preference.self, value: [geometry.size.width])
                })
            .onPreferenceChange(WidthPreference.self) { prefs in
                let maxPref = prefs.reduce(0, max)
                if maxPref > 0 {
                    self.width = maxPref
                }
            }
    }
}


struct HeightBindable: ViewModifier {

    typealias Preference = HeightPreference

    @Binding var height: CGFloat?

    func body(content: Content) -> some View {

        content
            .overlay(
                GeometryReader { geometry in
                    Color.clear.preference(key: Preference.self, value: [geometry.size.height])
                })
            .onPreferenceChange(Preference.self) { prefs in
                let maxPref = prefs.reduce(0, max)
                if maxPref > 0 {
                    self.height = maxPref
                }
            }
    }
}
