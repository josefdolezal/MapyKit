//
//  Directions.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 14/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Represents requested navigation data directions. Is tightly coupled
/// to the data given using the navigation request (e.g. total time
/// depends on requested transport type).
struct Directions {
    /// Geohash for list waypoints coordinates
    var coordinatesGeohash: String
    /// Distances between two following waypoint coordinates
    var distances: [Double]
    /// The total amount of elevation lost on the road
    var elevationLoss: Int
    /// The total amount of gained elevation on the road
    var elevationGain: Int
    /// Altitudes between two following waypoint coordinates
    var altitudes: [Int]
    /// The total time to get from start to destination (in seconds)
    var time: Int
}
