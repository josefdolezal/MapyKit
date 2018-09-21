//
//  Optional+FastRPCSerializable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

extension Optional: FastRPCSerializable where Wrapped: FastRPCSerializable {
    public func serialize() throws -> SerializationBuffer {
        switch self {
        // For `nil` value, send Null literal
        case .none:
            let nilIdentifier = FastRPCObejectType.nil.identifier

            return SerializationBuffer(data: nilIdentifier.usedBytes)
        // For `some` cases, serialize wrapped value
        case let .some(wrapped):
            return try wrapped.serialize()
        }
    }
}
