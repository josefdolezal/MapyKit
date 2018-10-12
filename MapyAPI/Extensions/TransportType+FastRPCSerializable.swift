//
//  TransportType+FastRPCSerializable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 28/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import FastRPCSwift

extension TransportType: FastRPCSerializable {
    public func serialize() throws -> SerializationBuffer {
        return try identifier.serialize()
    }
}

extension TransportType: Codable {
    public init(from decoder: Decoder) throws {
        // Create decoding container and decode raw value
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Int.self)

        // Try to map raw value to actual object
        guard let value = TransportType(rawValue: rawValue) else {
            // Throw error on invalid rawValue
            throw FastRPCDecodingError.corruptedData
        }

        // Initialize `self` based on raw value
        self = value
    }

    public func encode(to encoder: Encoder) throws {
        // Decode type as single int value
        var container = encoder.singleValueContainer()

        try container.encode(identifier)
    }
}
