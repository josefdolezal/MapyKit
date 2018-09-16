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
        case .none:
            return Data(FastRPCObejectType.nil.identifier)
        case let .some(wrapped):
            return try wrapped.serialize()
        }
    }
}