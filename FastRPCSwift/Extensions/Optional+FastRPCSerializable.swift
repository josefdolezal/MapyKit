//
//  Optional+FastRPCSerializable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

extension Optional: FastRPCSerializable where Wrapped: FastRPCSerializable {
    func serialize() throws -> Data {
        switch self {
        // For `nil` value, send Null literal
        case .none:
            var nilIdentifier = FastRPCObejectType.nil.identifier

            return  Data(bytes: &nilIdentifier, count: nilIdentifier.nonTrailingBytesCount)
        // For `some` cases, serialize wrapped value
        case let .some(wrapped):
            return try wrapped.serialize()
        }
    }
}
