//
//  FastRPCUnboxer.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 09/01/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import Foundation

public enum FastRPCProcedureKeys: String, CodingKey {
    case procedure
    case arguments
}

public enum FastRPCFaultKeys: String, CodingKey {
    case code
    case message
}

class FastRPCUnboxer {
    /// Data representing FRPC encoded object
    private var data: Data
    /// Version of the FRPC protocol used to decode stored object (default: 2.0)
    private var version: FastRPCProtocolVersion

    init(data: Data, version: FastRPCProtocolVersion = .version2) {
        self.data = data
        self.version = version
    }
    
    func unboxProcedure() throws -> Any {
        let type = try validateType()

        guard type == .nonDataType else {
            throw FastRPCSerializationError.unsupportedTopLevelIdentifier(type.identifier)
        }

        return try unboxNonDataType(required: .procedure)
    }

    func unboxResponse() throws -> Any {
        let type = try validateType()

        guard type == .nonDataType else {
            throw FastRPCSerializationError.unsupportedTopLevelIdentifier(type.identifier)
        }

        return try unboxNonDataType(required: .response)
    }

    func unboxFault() throws -> Any {
        let type = try validateType()

        guard type == .nonDataType else {
            throw FastRPCSerializationError.unsupportedTopLevelIdentifier(type.identifier)
        }

        return try unboxNonDataType(required: .fault)
    }

    // MARK: Unbox type evaluation

    private func unboxNestedValue() throws -> Any {
        // Get the data type
        let type = try validateType()

        switch type {
        // Primitives
        case .nil: return try unboxNil()
        case .bool: return try unbox(Bool.self)
        case .double: return try unbox(Double.self)
        case .int, .int8p, .int8n: return try unbox(Int.self)
        case .string: return try unbox(String.self)
        case .dateTime: return try unbox(Date.self)
        case .binary: return try unbox(Data.self)

        // Composite data types
        case .array: return try unbox(NSArray.self)
        case .struct: return try unbox(NSDictionary.self)

        // Non-data types wrapper identifier
        case .nonDataType: return try unboxNonDataType()

        // These must be wrapped inside non-data type
        case .procedure: throw FastRPCSerializationError.unsupportedTopLevelIdentifier(type.identifier)
        case .response: throw FastRPCSerializationError.unsupportedTopLevelIdentifier(type.identifier)
        case .fault: throw FastRPCSerializationError.unsupportedTopLevelIdentifier(type.identifier)
        }
    }

    // MARK: Unboxing API

    private func unbox(_ type: Bool.Type) throws -> Bool {
        // Get bool byte
        let bool = data.removeFirst()

        // Check bool by equality on LSB
        return bool & 1 == 1
    }

    private func unbox(_ type: Double.Type) throws -> Double {
        // Remove type information
        data.removeFirst()

        // Get double data (fixed size for IEEE 754)
        let bytes = try expectBytes(count: 8)

        // Convert raw data into double
        return bytes.withUnsafeBytes { $0.pointee }
    }

    private func unbox(_ type: Int.Type) throws -> Int {
        // Check first for type information (without last 3 additional info bits)
        guard let type = data.first.map({ Int($0 & 0xF8) }) else {
            throw FastRPCSerializationError.corruptedData(expectedBytes: 1, actualBytes: 0)
        }

        // Switch over int identifier
        switch type {
        case FastRPCObejectType.int8p.identifier: return try unboxPositiveInteger()
        case FastRPCObejectType.int8n.identifier: return try unboxNegativeInteger()
        case FastRPCObejectType.int.identifier:
            switch version {
            case .version1:
                return try unboxUnifiedInteger()
            case .version2:
                // Version 2 does not specify Int identifier (it uses separate Int8+/-),
                // so the identifier is unknown
                throw FastRPCSerializationError.unknownTypeIdentifier(type, version)
            case .version3:
                return try unboxZigZagInteger()
            }
        default:
            throw FastRPCSerializationError.unknownTypeIdentifier(type, version)
        }
    }

    private func unbox(_ type: String.Type) throws -> String {
        // For version 1, we do not use implicit addition for
        // count data size, with standard 2.0 and newer however
        // we have to add 1.
        let implicitCountAddition = version == .version1
            ? 0
            : 1

        // Get size of string data
        let info = try expectTypeAdditionalInfo()
        // Get string data length from additional data,
        // increase required count by one (FRPC standard)
        let lengthDataSize = Int(info) + implicitCountAddition
        // Get data containing info about string data length
        let stringLengthData = try expectBytes(count: lengthDataSize)
        // Get string length
        let stringDataSize = Int(data: stringLengthData)
        /// Get actual encoded string data
        let stringData = try expectBytes(count: stringDataSize)

        // Decode string data with utf8 encoding
        guard let string = String(data: stringData, encoding: .utf8) else {
            throw FastRPCSerializationError.corruptedStringEncoding(stringData)
        }

        return string
    }

    private func unbox(_ type: NSArray.Type) throws -> NSArray {
        // Get count of bytes keeping the array size
        let info = try expectTypeAdditionalInfo()
        // Get the number of elements (convert next `info + 1` bytes to Int)
        let size = try Int(data: expectBytes(count: Int(info + 1)))
        // Create the elements container
        let array = NSMutableArray()

        // Extract exactly `size` elements
        for _ in 0 ..< size {
            try array.add(unboxNestedValue())
        }

        return array
    }

    private func unbox(_ type: NSDictionary.Type) throws -> NSDictionary {
        // Get count of bytes keeping the number of members
        let info = try expectTypeAdditionalInfo()
        // Get number of members (convert next `info + 1` bytes to Int)
        let size = try Int(data: expectBytes(count: Int(info) + 1))
        /// Create the members container
        let structure = NSMutableDictionary()

        // Extract exactly `size` members
        for _ in 0 ..< size {
            // Get size of bytes keeping member name
            let nameSize = try Int(data: expectBytes(count: 1))
            // Get member name data
            let nameData = try expectBytes(count: nameSize)
            // Unbox member name UTF8 encoded string, fail decoding on error
            guard let name = String(data: nameData, encoding: .utf8) else {
                throw FastRPCSerializationError.corruptedStringEncoding(nameData)
            }
            // Unbox arbitrary value
            let value = try unboxNestedValue()

            // Save key-value pair into structure
            structure.setValue(value, forKey: name)
        }

        return structure
    }

    private func unboxPositiveInteger() throws -> Int {
        let info = try expectTypeAdditionalInfo()
        // Encode int size and increase it by 1 (FRPC standard)
        let dataSize = Int(info) + 1
        // Get expected bytes
        let bytes = try expectBytes(count: dataSize)

        // Return converted bytes
        return Int(data: bytes)
    }

    private func unboxNegativeInteger() throws -> Int {
        let info = try expectTypeAdditionalInfo()
        // Encode int size and increase it by 1 (FRPC standard)
        let dataSize = Int(info) + 1
        // Get expected bytes
        let bytes = try expectBytes(count: dataSize)
        // Convert data to integer
        let int = Int(data: bytes)

        return -int
    }

    private func unboxZigZagInteger() throws -> Int {
        let info = try expectTypeAdditionalInfo()
        // Get number of bytes encoding int
        let dataSize = Int(info) + 1
        // Get bytes representing the int
        let bytes = try expectBytes(count: dataSize)
        // Get the int value
        let int = Int(data: bytes)
        // Use unsigned int for logical bitwise shift
        let uint = UInt64(int)

        // Decode using zig zag
        return Int((uint >> 1)) ^ (-(int & 1))
    }

    /// Unboxes unified signed integer (used by standard FRPC 1.0).
    private func unboxUnifiedInteger() throws -> Int {
        // Get number of bytes used by integer
        let info = try expectTypeAdditionalInfo()
        // Get bytes representing integer
        let bytes = try expectBytes(count: Int(info))

        // Simply convert data into integer
        return Int(data: bytes)
    }

    private func unboxNil() throws -> NSObject {
        // Remove the nil byte
        data.removeFirst()

        // Represent nil using objc
        return NSNull()
    }

    private func unbox(_ type: Data.Type) throws -> Data {
        // Get bytes size of data count
        let info = try expectTypeAdditionalInfo()
        // Get info + 1 bytes which represents raw data count
        let size = try Int(data: expectBytes(count: Int(info + 1)))
        // Get the raw data
        let data = try expectBytes(count: size)

        return data
    }

    private func unbox(_ type: Date.Type) throws -> Date {
        // We don't need any additional info, just remove the info byte from queue
        _ = try expectTypeAdditionalInfo()
        // Remove the timezone info
        _ = try Int(data: expectBytes(count: 1))
        // Get the unix timestamps
        let timestamp = Int(data: try expectBytes(count: 4))
        let timeInterval = TimeInterval(timestamp)
        // Remove additional data informations (year, day of week, ...)
        _ = try expectBytes(count: 5)

        // We can ignore timezone and additional date data since
        // we use unix timestamp which is standardized in UTC timezone
        return Date(timeIntervalSince1970: timeInterval)
    }

    // MARK: Non-data types

    private func unboxNonDataType(required: FastRPCObejectType? = nil) throws -> Any {
        // Ignore the non-data type multi-byte identifier
        _ = try expectBytes(count: 2)
        // Get FRPC version
        let major = try Int(data: expectBytes(count: 1))
        let minor = try Int(data: expectBytes(count: 1))

        // Identify the procol version from type meta
        guard let version = FastRPCProtocolVersion(rawValue: major) else {
            throw FastRPCSerializationError.unsupportedProtocolVersion(major: major, minor: minor)
        }

        // Override currently used protocol version
        self.version = version

        // Check for the inner type
        let type = try validateType()

        // Check whether the actual type matches the required type
        guard required == nil || type == required else {
            throw FastRPCSerializationError.unknownTypeIdentifier(type.identifier, version)
        }

        // We only support subset of types as inner object
        switch type {
        case .response: return try _unboxResponse()
        case .procedure: return try _unboxProcedure()
        case .fault: return try _unboxFault()
        default:
            throw FastRPCSerializationError.unknownTypeIdentifier(type.identifier, version)
        }
    }

    private func _unboxProcedure() throws -> Any {
        // Ignore the additional type info
        _ = try expectTypeAdditionalInfo()
        // Get number of bytes used by procedure name
        let size = try Int(data: expectBytes(count: 1))
        // Get the procedure name data and convert it to string
        let nameData = try expectBytes(count: size)
        // Create temporary container for arguments unboxing
        var arguments = [Any]()

        // The name must be encoded using UTF8
        guard let name = String(data: nameData, encoding: .utf8) else {
            throw FastRPCSerializationError.corruptedStringEncoding(nameData)
        }

        // We expect the parameters to be lineary aligned
        while !data.isEmpty {
            arguments.append(try unboxNestedValue())
        }

        return NSDictionary(dictionary: [
            FastRPCProcedureKeys.procedure.rawValue: name,
            FastRPCProcedureKeys.arguments.rawValue: arguments
        ])
    }

    private func _unboxResponse() throws -> Any {
        // Remove the unused type information
        _ = try expectTypeAdditionalInfo()

        // Wrap remote response with internal type
        return try unboxNestedValue()
    }

    private func _unboxFault() throws -> Any {
        // Throw out fault response signature
        _ = try expectTypeAdditionalInfo()
        // Try to decode fault content
        let code = try unbox(Int.self)
        let message = try unbox(String.self)

        return NSDictionary(dictionary: [
            FastRPCFaultKeys.code.rawValue: code,
            FastRPCFaultKeys.message.rawValue: message
        ])
    }

    // MARK: Private API

    private func validateType() throws -> FastRPCObejectType {
        // Make the type info mutable so we can replace it with multibyte
        // representation later.
        guard var typeInfo = data.first.map({ Int($0 & 0xF8) }) else {
            throw FastRPCSerializationError.corruptedData(expectedBytes: 1, actualBytes: 0)
        }

        // Extend type to multibyte representation, add last three bytes by adding '2'
        let extendedTypeInfo = ((typeInfo + 2) << 8) + 0x11

        // Explicitly check for non-data type information, which uses two
        // bytes instead of typical one.
        if extendedTypeInfo == FastRPCObejectType.nonDataType.identifier {
            typeInfo = extendedTypeInfo
        }

        // Continue with original `typeInfo` property since multibyte encoding is
        // handled before.
        guard let type = FastRPCObejectType(rawValue: typeInfo) else {
            throw FastRPCSerializationError.unknownTypeIdentifier(typeInfo, version)
        }

        return type
    }

    private func expectBytes(count: Int) throws -> Data {
        // Check if we have required bytes count
        guard data.count >= count else {
            throw FastRPCSerializationError.corruptedData(expectedBytes: count, actualBytes: data.count)
        }

        // Get expected bytes and remove it
        let bytes = data.prefix(count)
        data.removeFirst(count)

        return bytes
    }

    private func expectTypeAdditionalInfo() throws -> UInt8 {
        guard data.first != nil else {
            throw FastRPCSerializationError.corruptedData(expectedBytes: 1, actualBytes: 0)
        }

        // Return just last three bits
        return data.removeFirst() & 0x07
    }
}
