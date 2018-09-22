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
/// - publicTransport: Navigation using public transport
/// - bike: Navigation for bike
/// - foot: Foot navigation
/// - skiing: Cross country skiing navigation
/// - boat: Canoeing navigation
public enum TransportType: FastRPCSerializable {
    case car(PreferredAttributes)
    case publicTransport
    case bike(BikeType)
    case foot(TourType)
    case skiing
    case boat

    /// Remote API transport type identifier
    var identifier: Int {
        switch self {
        case .car: return 1
        case .publicTransport: return 2
        case .bike: return 3
        case .foot: return 4
        case .skiing: return 5
        case .boat: return 6
        }
    }

    // MARK: FastRPCSerializable

    public func serialize() throws -> SerializationBuffer {
        return try identifier.serialize()
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
