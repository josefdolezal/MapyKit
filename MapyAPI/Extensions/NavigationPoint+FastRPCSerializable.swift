//
//  NavigationPoint+FastRPCSerializable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 28/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import FastRPCSwift

extension NavigationPoint: FastRPCSerializable {
    public func serialize() throws -> SerializationBuffer {
        let container = KeyedSerializationContainer(for: CodingKeys.self)

        try container.serialize(value: id, for: .id)
        // Currently, we only support coordinates as navigatiom points, so it's OK to hardcode it
        try container.serialize(value: "coor", for: .source)
        try container.serialize(value: coordinates, for: .coordinates)

        // Serialize transport only if it's available
        if let transportType = transportType {
            try container.serialize(value: ["criterion": transportType.identifier], for: .transportType)
        }

        // Since we don't use description parameters, add dummy empty object
        try container.serialize(value: descriptionParameters, for: .descriptionParameters)

        return container.createBuffer()
    }
}

extension NavigationPoint.DescriptionParams: FastRPCSerializable {
    internal func serialize() throws -> SerializationBuffer {
        let container = SerializationContainer()

        try container.serialize(value: fetchPhoto, for: "fetchPhoto")
        try container.serialize(value: ratios, for: "ratios")
        try container.serialize(value: lang, for: "lang")

        return container.createBuffer()
    }
}

extension NavigationPoint: Codable {
    fileprivate enum DescriptionCodingKeys: String, CodingKey {
        case fetchPhoto
        case ratio = "ratios"
        case lang
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.coordinates = try container.decode(Location.self, forKey: .coordinates)
        self.transportType = try container.decodeIfPresent(TransportType.self, forKey: .transportType)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        // Currently, we only support coordinates as navigatiom points, so it's OK to hardcode it
        try container.encode("coor", forKey: .source)
        try container.encode(coordinates, forKey: .coordinates)

        // Serialize transport only if it's available
        if let transportType = transportType {
            var transportContainer = encoder.container(keyedBy: CodingKeys.self)

            try transportContainer.encode(transportType.identifier, forKey: .transportCriterio)
        }

        // Since we don't use description parameters, add dummy empty object
        var descriptionContainer = encoder.container(keyedBy: DescriptionCodingKeys.self)

        try descriptionContainer.encode(true, forKey: .fetchPhoto)
        try descriptionContainer.encode(["3x2"], forKey: .ratio)
        try descriptionContainer.encode(["en"], forKey: .lang)
    }
}
