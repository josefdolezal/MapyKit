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

    enum CodingKeys: String, CodingKey {
        case id
        case source
        case geometry
        case transportType = "routeParams"
        case descriptionParameters = "descParams"
    }

    internal struct DescriptionParams {
        var fetchPhoto: Bool
        var ratios: [String]
        var lang: [String]

        static let test = DescriptionParams(fetchPhoto: true, ratios: ["3x2"], lang: ["en"])
    }

    // MARK: Properties

    /// Point identifier (optional, `nil` for coordiantes-only points)
    public var id: Int?
    /// Source of point
    public var source: String
    /// Point geometry
    public var geometry: String
    /// Navigation transport type, must be set for starting point
    public var transportType: TransportType?

    // MARK: Initializers

    /// Creates new navigation point. This object may be used to determine route navigation steps.
    ///
    /// - Parameters:
    ///   - id: Point identifier
    ///   - source: Source of the geometry value
    ///   - geometry: Point geometry
    ///   - transportType: Type of transport (required for starting position)
    public init(id: Int? = nil, source: String, geometry: String, transportType: TransportType? = nil) {
        self.id = id
        self.source = source
        self.geometry = geometry
        self.transportType = transportType
    }
}
