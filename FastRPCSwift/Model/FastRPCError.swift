//
//  FastRPCError.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Remote procedure call error. Wraps both request and response error.
///
/// - serialization: Error which occured during serialization. First argument is object which could not be serialized, second contains underlying error (if any).
/// - unknown: Unknown error. May occure due unexpected internal inconsistency.
public enum FastRPCError: Error {
    case requestEncoding(Any, Error?)
    case responseDecoding(Data, Error?)
    case unknown(Error?)
}

public enum FastRPCSerializationError: Error {
    case corruptedData(expectedBytes: Int, actualBytes: Int)
    case unsupportedTopLevelObject(Any)
    case unsupportedTopLevelIdentifier(Int)
    case unknownTypeIdentifier(Int, FastRPCProtocolVersion)
    case unsupportedObject(Any)
    case unsupportedFieldNameObject(Any)
    case corruptedStringFormat(String)
    case corruptedStringEncoding(Data)
    case unsupportedProtocolVersion(major: Int, minor: Int)
}
