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

public struct FastRPCEncoder {
    public func encode<T: Encodable>(_ value: T) throws -> Data {
        fatalError()
    }
}

class _FastRPCEncoder: Encoder, SingleValueEncodingContainer {
    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey : Any] = [:]

    private var data = Data()

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        fatalError()
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }

    // MARK: SingleValueEncodingContainer

    func encodeNil() throws {
        fatalError()
    }

    func encode(_ value: Bool) throws {
        fatalError()
    }

    func encode(_ value: String) throws {
        // Try ot convert UTF8 string into data
        guard let stringData = value.data(using: .utf8) else {
            // Throw error on failure
            throw FastRPCError.serialization(self, nil)
        }

        // Encode data size into bytes
        let dataBytesSize = stringData.count.usedBytes
        // Create identifier (id + encoded data size)
        let identifier = FastRPCObejectType.string.identifier + (dataBytesSize.count - 1)
        // Create data container for final encoded value
        var data = identifier.usedBytes

        // Combine identifier, content length and content
        data.append(dataBytesSize)
        data.append(stringData)

        // Return converted data
        self.data.append(data)
    }

    func encode(_ value: Double) throws {
        // Create identifier exactly 1B in length
        let identifierData = FastRPCObejectType.double.identifier.usedBytes
        // Serialize double using IEEE 754 standard (exactly 8B)
        var bitRepresentation = value.bitPattern
        let data = Data(bytes: &bitRepresentation, count: bitRepresentation.bitWidth / 8)

        // Combbine identifier with number data
        self.data.append(identifierData)
        self.data.append(data)
    }

    func encode(_ value: Int) throws {
        // Determine the type of current value
        let type: FastRPCObejectType = value < 0
            ? .int8n
            : .int8p
        // Create copy of `self` and ignore it's sign
        var copy = abs(value)
        // Create identifier using type ID increased by NLEN
        var identifier = type.identifier + (copy.nonTrailingBytesCount - 1)

        // Create data from identifier (alway 1B lenght)
        var identifierData = Data(bytes: &identifier, count: 1)
        let intData = Data(bytes: &copy, count: copy.nonTrailingBytesCount)

        // Concat data (type + value)
        identifierData.append(intData)

        // Stored encoded value
        self.data.append(identifierData)
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        try value.encode(to: self)
    }

    // MARK: SingleValueEncodingContainer - Unsupported types

    func encode(_ value: Int8) throws {
        fallImplementationNotice(from: Int8.self, to: Int.self)

        try encode(Int(value))
    }

    func encode(_ value: Int16) throws {
        fallImplementationNotice(from: Int16.self, to: Int.self)

        try encode(Int(value))
    }

    func encode(_ value: Int32) throws {
        fallImplementationNotice(from: Int32.self, to: Int.self)

        try encode(Int(value))
    }

    func encode(_ value: Int64) throws {
        fallImplementationNotice(from: Int64.self, to: Int.self)

        try encode(Int(value))
    }

    func encode(_ value: UInt) throws {
        fallImplementationNotice(from: UInt.self, to: Int.self)

        try encode(Int(value))
    }

    func encode(_ value: UInt8) throws {
        fallImplementationNotice(from: UInt8.self, to: Int.self)

        try encode(Int(value))
    }

    func encode(_ value: UInt16) throws {
        fallImplementationNotice(from: UInt16.self, to: Int.self)

        try encode(Int(value))
    }

    func encode(_ value: UInt32) throws {
        fallImplementationNotice(from: UInt32.self, to: Int.self)

        try encode(Int(value))
    }

    func encode(_ value: UInt64) throws {
        fallImplementationNotice(from: UInt64.self, to: Int.self)

        try encode(Int(value))
    }

    func encode(_ value: Float) throws {
        fallImplementationNotice(from: Float.self, to: Double.self)

        try encode(Double(value))
    }

    // MARK: Private API

    private func fallImplementationNotice<From, To>(from: From.Type, to: To.Type) {
        debugPrint("[FastFRPCSwift] Required type \(from) is not supported by FastRPC standard. The value will be encoded as \(to) which may cause undefined behavior.")
    }
}
