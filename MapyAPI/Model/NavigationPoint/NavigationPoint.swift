//
//  NavigationPoint.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 23/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Navigation point representing start, destionation or way through points.
public struct NavigationPoint: Encodable {
    // MARK: Structure
    /// Custom coding keys
    internal enum CodingKeys: String, CodingKey {
        case id
        case coordinates = "geometry"
        case transportType = "routeParams"
        case descriptionParameters = "descParams"
        case source
    }

    // MARK: Properties

    /// Point identifier (optional, `nil` for coordiantes-only points)
    public var id: String?
    /// Point coordinates
    public var coordinates: Location
    /// Navigation transport type, must be set for starting point
    public var transportType: TransportType?

    /// Use internal singleton for nested objects
    internal let descriptionParameters = DescriptionParams.default
    /// Coordinates source
    internal let source = Source.coordinates

    // MARK: Initializers

    /// Creates new navigation point. This object may be used to determine route navigation steps.
    ///
    /// - Parameters:
    ///   - id: Point identifier
    ///   - coordinates: Pont coordinates
    ///   - transportType: Type of transport (required for starting position)
    public init(id: String? = nil, coordinates: Location, transportType: TransportType? = nil) {
        self.id = id
        self.coordinates = coordinates
        self.transportType = transportType
    }
}
