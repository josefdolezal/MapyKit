//
//  Double+FastRPCSerializable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

extension Double: FastRPCSerializable {
    public func serialize() throws -> SerializationBuffer {
        // Create identifier exactly 1B in length
        var identifier = FastRPCObejectType.double.identifier
        var identifierData = Data(bytes: &identifier, count: 1)

        // Serialize double using IEEE 754 standard (exactly 8B)
        var bitRepresentation = bitPattern
        let doubleData = Data(bytes: &bitRepresentation, count: bitRepresentation.bitWidth / 8)

        // Combbine identifier with number data
        identifierData.append(doubleData)

        return SerializationBuffer(data: identifierData)
    }
}
