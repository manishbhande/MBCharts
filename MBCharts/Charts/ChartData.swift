//
//  ChartData.swift
//  SwiftUIDashboard
//
//  Created by Manish on 27/07/2020.
//  Copyright © 2020 Manish. All rights reserved.
//

import SwiftUI

protocol ChartDataID { }

// MARK: - ChartData
protocol ChartData {

    var id: ChartDataID? { get set }
}


// MARK:- ChartPoints
protocol ChartPoint {

    var id: ChartDataID? { get set }

}
