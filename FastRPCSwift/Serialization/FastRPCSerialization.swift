//
//  FastRPCSerialization.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

public enum FastRPCDecodingError: Error {
    case missingTypeIdentifier
    case unknownTypeIdentifier
    case corruptedData
    case unexpectedTopLevelObject
    case unsupportedNonDataType
    case unsupportedProtocolVersion(major: Int, minor: Int)
    case keyNotFound(CodingKey)
    case typeMismatch(expected: Any, actual: Any)
    case unsupportedType(Any, replacement: Any)
    case containerIsAtEnd
}

public class FastRPCSerialization {

    private init () { }

    static func frpcProcedure(with data: Data) throws -> Any { // T
        return try FastRPCUnboxer(data: data).unboxProcedure()
    }

    static func frpcResponse(with data: Data) throws -> Any { // NSDictionary
        return try FastRPCUnboxer(data: data).unboxResponse()
    }

    static func frpcFault(with data: Data) throws -> Any { // NSDict
        return try FastRPCUnboxer(data: data).unboxFault()
    }

    static func data(procedure: String, arguments: [Any], version: FastRPCProtocolVersion = .version2) throws -> Data {
        let boxer = FastRPCBoxer(version: version)

        return try boxer.box(procedure: procedure, arguments: arguments)
    }

    static func data(response: Any, version: FastRPCProtocolVersion = .version2) throws -> Data {
        let boxer = FastRPCBoxer(version: version)

        return try boxer.box(response: response)
    }

    static func data(faultCode code: Int, message: String, version: FastRPCProtocolVersion = .version2) throws -> Data {
        let boxer = FastRPCBoxer(version: version)

        return try boxer.box(faultCode: code, message: message)
    }
}
