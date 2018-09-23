//
//  NavigationPoint.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 23/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import FastRPCSwift

/// Navigation point representing start, destionation or way through points.
public struct NavigationPoint: FastRPCSerializable {
    // MARK: Structure

    enum CodingKeys: String, CodingKey {
        case id
        case source
        case geometry
        case transportType = "routeParams"
        case descriptionParameters = "descParams"
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

    // MARK: FastRPCSerializable

    public func serialize() throws -> SerializationBuffer {
        let container = KeyedSerializationContainer(for: CodingKeys.self)

        try container.serialize(value: id, for: .id)
        try container.serialize(value: source, for: .source)
        try container.serialize(value: geometry, for: .geometry)

        // Serialize transport only if it's available
        if let transportType = transportType {
            try container.serialize(value: ["criterion": transportType.identifier], for: .transportType)
        }

        // Since we don't use description parameters, add dummy empty object
        try container.serialize(value: [String: Int](), for: .descriptionParameters)

        return container.createBuffer()
    }
}
