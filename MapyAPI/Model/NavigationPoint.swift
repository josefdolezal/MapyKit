//
//  NavigationPoint.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 23/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import FastRPCSwift

/// Navigation point representing start, destionation or way through points.
public struct NavigationPoint {
    // MARK: Structure

    internal enum CodingKeys: String, CodingKey {
        case id
        case source
        case coordinates = "geometry"
        case transportType = "routeParams"
        case descriptionParameters = "descParams"
    }

    /// Fake nested object used for FRPC serialization (syntax sugar for nested objects is not ready yet)
    internal struct DescriptionParams {
        var fetchPhoto: Bool
        var ratios: [String]
        var lang: [String]

        static let fixed = DescriptionParams(fetchPhoto: true, ratios: ["3x2"], lang: ["en"])
    }

    // MARK: Properties

    /// Point identifier (optional, `nil` for coordiantes-only points)
    public var id: Int?
    /// Point coordinates
    public var coordinates: Location
    /// Navigation transport type, must be set for starting point
    public var transportType: TransportType?
    /// Use internal singleton for nested objects
    internal let descriptionParameters = DescriptionParams.fixed

    // MARK: Initializers

    /// Creates new navigation point. This object may be used to determine route navigation steps.
    ///
    /// - Parameters:
    ///   - id: Point identifier
    ///   - coordinates: Pont coordinates
    ///   - transportType: Type of transport (required for starting position)
    public init(id: Int? = nil, coordinates: Location, transportType: TransportType? = nil) {
        self.id = id
        self.coordinates = coordinates
        self.transportType = transportType
    }
}
