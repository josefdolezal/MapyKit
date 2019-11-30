//
//  FastRPCEncoder.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 06/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

public struct FastRPCEncoder {
    private let jsonEncoder = JSONEncoder()

    // MARK: Initializers

    public init() { }

    // MARK: Public API - Procedure

    public func encode(procedure: String, version: FastRPCProtocolVersion = .version2) throws -> Data {
        return try FastRPCSerialization.data(procedure: procedure, arguments: [], version: version)
    }

    public func encode<T: Encodable>(procedure: String, _ arg1: T, version: FastRPCProtocolVersion = .version2) throws -> Data {
        return try FastRPCSerialization.data(procedure: procedure, arguments: [serialize(arg1)], version: version)
    }

    public func encode<T: Encodable, U: Encodable>(procedure: String, _ arg1: T, _ arg2: U, version: FastRPCProtocolVersion = .version2) throws -> Data {
        return try FastRPCSerialization.data(procedure: procedure, arguments: [serialize(arg1), serialize(arg2)], version: version)
    }

    public func encode<T: Encodable, U: Encodable, V: Encodable>(procedure: String, _ arg1: T, _ arg2: U, _ arg3: V, version: FastRPCProtocolVersion = .version2) throws -> Data {
        return try FastRPCSerialization.data(procedure: procedure, arguments: [serialize(arg1), serialize(arg2), serialize(arg3)], version: version)
    }

    // MARK: Public API - Fault

    public func encode(faultCode code: Int, message: String) throws -> Data {
        return try FastRPCSerialization.data(faultCode: code, message: message)
    }

    // MARK: Public API - Response

    public func encode<T: Encodable>(response value: T) throws -> Data {
        return try FastRPCSerialization.data(response: serialize(value))
    }

    // MARK: Private API

    private func serialize<T: Encodable>(_ value: T) throws -> Any {
        let data = try jsonEncoder.encode(value)
        return try JSONSerialization.jsonObject(with: data, options: [])
    }
}
