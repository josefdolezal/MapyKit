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

public enum FastRPCDecodingError: Error {
    case missingTypeIdentifier
    case unknownTypeIdentifier
    case corruptedData
}

public class FastRPCSerialization {

    private init () {
        
    }

    static func object(with data: Data) throws -> Any {
        let unboxer = FastRPCUnboxer(data: data)

        return try unboxer.unbox()
    }

    static func data(withObject object: Any) throws -> Data {
        fatalError()
    }
}

private class FastRPCUnboxer {
    private var data: Data

    init(data: Data) {
        self.data = data
    }

    public func unbox() throws -> Any {
        let type = try validateType()

        switch type {
        case .nil: return try unboxNil()
        case .bool: return try unbox(Bool.self)
        case .double: return try unbox(Double.self)
        case .int, .int8p, .int8n: return try unbox(Int.self)
        case .string: return try unbox(String.self)
        case .dateTime: return try unbox(Date.self)
        case .binary: return try unbox(Data.self)

        case .nonDataType: fatalError()
        case .procedure: fatalError()
        case .response: fatalError()
        case .fault: fatalError()

        case .array: return try unbox(NSArray.self)
        case .struct: return try unbox(NSDictionary.self)
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
        let type = Int(data.removeFirst() & 0xF8)

        // Switch over int identifier
        switch type {
        case FastRPCObejectType.int8p.identifier: return try unboxPositiveInteger()
        case FastRPCObejectType.int8n.identifier: return try unboxNegativeInteger()
        case FastRPCObejectType.int.identifier: return try unboxZigZagInteger()
        default:
            throw FastRPCDecodingError.unknownTypeIdentifier
        }
    }

    private func unbox(_ type: String.Type) throws -> String {
        // Get size of string data
        let info = try expectTypeAdditionalInfo()
        // Get string data length from additional data,
        // increase required count by one (FRPC standard)
        let lengthDataSize = Int(info) + 1
        // Get data containing info about string data length
        let stringLengthData = try expectBytes(count: lengthDataSize)
        // Get string length
        let stringDataSize = Int(data: stringLengthData)
        /// Get actual encoded string data
        let stringData = try expectBytes(count: stringDataSize)

        // Decode string data with utf8 encoding
        guard let string = String(data: stringData, encoding: .utf8) else {
            throw FastRPCDecodingError.corruptedData
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
            try array.add(unbox())
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
                throw FastRPCDecodingError.corruptedData
            }
            // Unbox arbitrary value
            let value = try unbox()

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
        fatalError()
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

    // MARK: Private API

    private func validateType() throws -> FastRPCObejectType {
        guard let typeInfo = data.first else {
            throw FastRPCDecodingError.missingTypeIdentifier
        }

        guard let type = FastRPCObejectType(rawValue: Int(typeInfo)) else {
            throw FastRPCDecodingError.unknownTypeIdentifier
        }

        return type
    }

    private func expectBytes(count: Int) throws -> Data {
        // Check if we have required bytes count
        guard data.count >= count else {
            throw FastRPCDecodingError.corruptedData
        }

        // Get expected bytes and remove it
        let bytes = data.prefix(count)
        data.removeFirst(count)

        return bytes
    }

    private func expectTypeAdditionalInfo() throws -> UInt8 {
        guard data.first != nil else {
            throw FastRPCDecodingError.missingTypeIdentifier
        }

        // Return just last three bits
        return data.removeFirst() & 0x07
    }
}
