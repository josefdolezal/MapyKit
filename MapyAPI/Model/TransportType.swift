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
    // MARK: Structure

    case car(PreferredAttributes)
    case bike(BikeType)
    case foot(TourType)
    case skiing
    case boat

    // MARK: Initializers

    init?(rawValue: Int) {
        switch rawValue {
        case 111: self = .car(.fast)
        case 113: self = .car(.short)
        case 121: self = .bike(.mountain)
        case 122: self = .bike(.road)
        case 131: self = .foot(.short)
        case 132: self = .foot(.touristic)
        case 141: self = .skiing
        case 143: self = .boat
        default:
            return nil
        }
    }

    // MARK: Public API

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
