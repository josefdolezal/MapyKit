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

    // MARK: Decoding

    public static func frpcProcedure(with data: Data) throws -> Any {
        return try FastRPCUnboxer(data: data).unboxProcedure()
    }

    public static func frpcResponse(with data: Data) throws -> Any {
        return try FastRPCUnboxer(data: data).unboxResponse()
    }

    public static func frpcFault(with data: Data) throws -> Any {
        return try FastRPCUnboxer(data: data).unboxFault()
    }

    // MARK: Encoding

    public static func data(procedure: String, arguments: [Any], version: FastRPCProtocolVersion = .version2) throws -> Data {
        let boxer = FastRPCBoxer(version: version)

        return try boxer.box(procedure: procedure, arguments: arguments)
    }

    public static func data(response: Any, version: FastRPCProtocolVersion = .version2) throws -> Data {
        let boxer = FastRPCBoxer(version: version)

        return try boxer.box(response: response)
    }

    public static func data(faultCode code: Int, message: String, version: FastRPCProtocolVersion = .version2) throws -> Data {
        let boxer = FastRPCBoxer(version: version)

        return try boxer.box(faultCode: code, message: message)
    }
}
