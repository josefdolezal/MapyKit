//
//  FastRPCDecoder.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 06/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

public struct FastRPCDecoder {
    // MARK: Initializers

    public init() { }

    // MARK: Public API

    public func decodeResponse<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        let unboxedResponse = try FastRPCSerialization.frpcResponse(with: data)
        let serializedData = try JSONSerialization.data(withJSONObject: unboxedResponse, options: [])

        return try JSONDecoder().decode(type, from: serializedData)
    }

    public func decodeProcedure<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        let unboxedProcedure = try FastRPCSerialization.frpcProcedure(with: data)
        let serializedData = try JSONSerialization.data(withJSONObject: unboxedProcedure, options: [])

        return try JSONDecoder().decode(type, from: serializedData)
    }

    public func decodeFault(from data: Data) throws -> (code: Int, message: String) {
        let unboxedFault = try FastRPCSerialization.frpcFault(with: data)

        guard
            let dictionary = unboxedFault as? NSDictionary,
            let code = dictionary.object(forKey: FastRPCFaultKeys.code) as? Int,
            let message = dictionary.object(forKey: FastRPCFaultKeys.message) as? String
        else {
            assertionFailure("Internal inconsistency: successfuly unboxed fault but it's data has unexpected format.")
            return (0, "")
        }

        return (code, message)
    }
}
