//
//  ChartAlignment.swift
//  SwiftUIDashboard
//
//  Created by Manish on 28/07/2020.
//  Copyright © 2020 Manish. All rights reserved.
//

import SwiftUI

enum ChartAlignment {

    static func align<C, L>(chart: C, legends: L, style: LegendStyle) -> some View where C: View, L: View {

        ZStack {
            switch (style.verticalAlignment, style.horizontalAlignment) {

            //MARK:- Leading
            case (.leading, .top):
                VStack {
                    HStack {
                        legends
                        Spacer()
                    }
                    chart
                }

            case (.leading, .center):
                HStack {
                    legends
                    chart
                }

            case (.leading, .bottom):
                VStack {
                    chart
                    HStack {
                        legends
                        Spacer()
                    }
                }

            //MARK:- Trailing
            case (.trailing, .top):
                VStack {
                    HStack {
                        Spacer()
                        legends
                    }
                    chart
                }

            case (.trailing, .center):
                HStack {
                    chart
                    legends
                }

            case (.trailing, .bottom):
                VStack {
                    chart
                    HStack {
                        Spacer()
                        legends
                    }
                }

            // MARK:-  Center
            case (.center, .top):
                VStack {
                    legends
                    chart
                }

            case (.center, .center):
                ZStack {
                    chart
                    legends
                }

            case (.center, .bottom):
                VStack {
                    chart
                    legends
                }
            }
        }
    }
}
