//
//  Dictionary+FastRPCSerializable.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 23/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

extension Dictionary: FastRPCSerializable where Key == String, Value: FastRPCSerializable {
    public func serialize() throws -> SerializationBuffer {
        // Create empty untyped container
        let container = SerializationContainer()

        // Encode all values by it's keys
        for (key, value) in self {
            try container.serialize(value: value, for: key)
        }

        return container.createBuffer()
    }
}
