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
