//
//  SerializationContainer.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 17/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Serialization container takes care data of serialization using FRPC. It exposes high-level
/// API for serialing structured objects and language primitives while maintaing serialized
/// data valid with FRPS standard. For primitive serialization use `PrimitiveSerializationContainer`.
public final class SerializationContainer {
    // MARK: - Properties

    /// Internal representation of given structured members. Each member is
    /// FRPC encoded key-value pair.
    private var members: [Data]

    // MARK: - Initializers

    /// Public initializer for creating serialization container. Creates new empty container.
    public init() {
        self.members = []
    }

    // MARK: Public API

    /// Creates serialization buffer for given structure.
    ///
    /// - Returns: New serialization buffer.
    public func createBuffer() -> SerializationBuffer {
        // Struct data storage
        var data = Data()
        // Serialize identifier
        let identifier = FastRPCObejectType.struct.identifier + members.count.nonTrailingBytesCount - 1
        data.append(identifier.usedBytes)
        data.append(members.count.usedBytes)

        // Serialize data by merging members data
        let membersData = members.reduce(Data(), +)
        // Append members data to the end of data buffer
        data.append(membersData)

        return SerializationBuffer(data: data)
    }

    /// Serialize Bool value into buffer under given key.
    ///
    /// - Parameters:
    ///   - value: The value to be serialized
    ///   - key: Serialization key
    /// - Throws: FastRPCError
    public func serialize(value: FastRPCSerializable, for key: String) throws {
        // Encode the value name using .utf8
        guard let keyData = key.data(using: .utf8) else {
            throw FastRPCError.serialization(key, nil)
        }

        // Create initial data from encoded key length
        var data = keyData.count.truncatedBytes(to: 1)

        // Append encoded key, value and then append encoded member into internal storage
        data.append(keyData)
        try data.append(value.serialize().data)
        members.append(data)
    }
}

struct FastRPCDecoder {
    public func decode<T: Decodable>(_ value: T.Type, from data: Data) throws -> T {
        let decoder = _FastRPCDecoder(data: data)

        return try T(from: decoder)
    }
}

struct _FastRPCDecoder: Decoder, SingleValueDecodingContainer {
    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey : Any] = [:]

    private var data: Data

    init(data: Data) {
        self.data = data
    }

    // MARK: - Decoder

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        fatalError()
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }

    // MARK: SingleValueDecodingContainer (Primitives)

    func decodeNil() -> Bool {
        // We decode nil only if first byte is nil literal
        guard let byte = data.first else {
            return false
        }

        return byte == UInt8(FastRPCObejectType.nil.identifier)
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        try expectNonNull(type, with: FastRPCObejectType.bool)

        let bool = data.popFirst()!

        // The bool value is encoded in the last bit
        return bool & 1 == 1
    }

    mutating func decode(_ type: String.Type) throws -> String {
        try expectNonNull(type, with: FastRPCObejectType.string)

        // Increase required count by one (FRPC standard)
        let dataSize = Int((data.popFirst()! & 0x07) + 1)

        // Check whether the container has enough data for decoding
        guard dataSize <= data.count else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(dataSize)B of string data, got \(data.count)B instead."))
        }

        // Remove string data from container
        let stringData = data.prefix(dataSize)
        data.removeFirst(dataSize)

        // Decode string data with utf8 encoding
        guard let string = String(data: stringData, encoding: .utf8) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Given data cannot be decoded using UTF8."))
        }

        return string
    }

    func decode(_ type: Int.Type) throws -> Int {
        fatalError()
    }

    func decode(_ type: Double.Type) throws -> Double {
        fatalError()
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        fatalError()
    }

    // MARK: SingleValueDecodingContainer (Unsupported types)

    func decode(_ type: Float.Type) throws -> Float {
        let double = try decode(Double.self)

        fallbackImplementationNotice(from: type, to: Double.self)

        return Float(double)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        let int = try decode(Int.self)

        fallbackImplementationNotice(from: type, to: Int.self)

        return Int8(int)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        let int = try decode(Int.self)

        fallbackImplementationNotice(from: type, to: Int.self)

        return Int16(int)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        let int = try decode(Int.self)

        fallbackImplementationNotice(from: type, to: Int.self)

        return Int32(int)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        let int = try decode(Int.self)

        fallbackImplementationNotice(from: type, to: Int.self)

        return Int64(int)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        let int = try decode(Int.self)

        fallbackImplementationNotice(from: type, to: Int.self)

        return UInt(int)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        let int = try decode(Int.self)

        fallbackImplementationNotice(from: type, to: Int.self)

        return UInt8(int)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        let int = try decode(Int.self)

        fallbackImplementationNotice(from: type, to: Int.self)

        return UInt16(int)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        let int = try decode(Int.self)

        fallbackImplementationNotice(from: type, to: Int.self)

        return UInt32(int)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        let int = try decode(Int.self)

        fallbackImplementationNotice(from: type, to: Int.self)

        return UInt64(int)
    }

    // MARK: Private API

    private func expectNonNull<T>(_ type: T.Type, with objectType: FastRPCObejectType) throws {
        // Do not allow null values on stack
        guard !self.decodeNil() else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(type) but found null value instead."))
        }

        guard
            // Dequeu type information (mask off last three bits)
            let typeByte = data.first.map({ $0 & 0xF8 }),
            // Compare actual type with required type
            objectType.identifier == typeByte
        else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Expected type information for \(type) (\(objectType.identifier) but got null value or incorrect information instead."))
        }
    }

    private func fallbackImplementationNotice<T, U>(from required: T.Type, to fallback: U.Type) where U: Decodable {
        debugPrint("[FastFRPCSwift] Required type \(required) is not supported by FastRPC standard. The value will be decoded as \(fallback) which may cause undefined behavior.")
    }
}
