//
//  FastRPCObejectType.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Groups all available FastRPC objects type.
/// Contains required type identifier for serialization.
///
/// - `nil`: Represents empty state for optional value. Equivalent to Swift `nil` literal.
/// - procedure: Identifier for RPC method call/name.
/// - binary: Raw binary data.
/// - fault: Remote procedure call failure.
/// - nonDataType: Marks content as non data type. Uses 2B.
/// - response: Represents request response.
/// - bool: Boolean value.
/// - dateTime: Represents structured datetime format.
/// - double: Double value.
/// - int: Integer value.
/// - int8n: Negative integer value (numbers less then or equal to zero).
/// - int8p: Positive integer value (greater then zero).
/// - string: ASCII encoded UTF8 string (keep in mind variable bytes count for UTF8 chars).
/// - array: Homogenous array of RPCSerializable objects.
/// - `struct`: Structured key-value object.
public enum FastRPCObejectType: Int {
    // MARK: Meta

    case `nil` = 12
    case procedure = 13
    case binary = 6
    case fault = 15
    case nonDataType = 0x11CA
    case response = 14

    // MARK: Primitive

    case bool = 2
    case dateTime = 5
    case double = 3
    case int = 1
    case int8n = 8
    case int8p = 7
    case string = 4

    // MARK: Composite

    case array = 11
    case `struct` = 10

    // MARK: Properties

    /// FastRPC data serialization format.
    var identifier: Int {
        switch self {
        case .nonDataType: return rawValue
        default: return rawValue << 3
        }
    }
}
