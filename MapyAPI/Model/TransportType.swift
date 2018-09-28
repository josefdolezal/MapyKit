//
//  TransportType.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 22/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation
import FastRPCSwift

/// Transport type used for navigation purpose. Some transport types require additional
/// informations to make navigation roads more reliable.
///
/// - car: Navigation for car
/// - bike: Navigation for bike
/// - foot: Foot navigation
/// - skiing: Cross country skiing navigation
/// - boat: Canoeing navigation
public enum TransportType {
    case car(PreferredAttributes)
    case bike(BikeType)
    case foot(TourType)
    case skiing
    case boat

    /// Remote API transport type identifier
    var identifier: Int {
        switch self {
        case .car(.fast): return 111
        case .car(.short): return 113
        case .bike(.mountain): return 121
        case .bike(.road): return 122
        case .foot(.short): return 131
        case .foot(.touristic): return 132
        case .skiing: return 141
        case .boat: return 143
        }
    }
}

/// Prefered route attributes.
///
/// - fast: Prefers fastest route (measured by ETA)
/// - short: Prefers short route (measured by total distance)
public enum PreferredAttributes {
    case fast
    case short
}

/// Bike type.
///
/// - mountain: Mountain bike for terrain cycling
/// - road: Road-only bike
public enum BikeType {
    case mountain
    case road
}

/// Foot tour type.
///
/// - short: Shortest route (measured by total distance)
/// - touristic: Route preferring touristic trails
public enum TourType {
    case short
    case touristic
}
