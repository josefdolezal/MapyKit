//
//  FastRPCSerializable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Object which is able to be serialized through FastRPC protocol.
public protocol FastRPCSerializable {
    /// Returns raw data representing object in FastRPC protocol.
    /// Throws FastRPC error if object is not serializable.
    ///
    /// - Returns: Raw data representing structure
    /// - Throws: FastRPCError on failure
    func serialize() throws -> SerializationBuffer
}
