//
//  TransportType+TourType.swift
//  MapyAPI
//
//  Created by Josef Dolezal (Admin) on 01/12/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import Foundation

/// Foot tour type.
///
/// - short: Shortest route (measured by total distance)
/// - touristic: Route preferring touristic trails
public enum TourType {
    case short
    case touristic
}
