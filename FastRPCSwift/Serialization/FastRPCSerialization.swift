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

    static func object(with data: Data) throws -> Any {
        let unboxer = FastRPCUnboxer(data: data)

        return try unboxer.unbox()
    }

    static func data(withObject object: Any) throws -> Data {
        let boxer = FastRPCBoxer(container: object)

        return try boxer.box()
    }
}
