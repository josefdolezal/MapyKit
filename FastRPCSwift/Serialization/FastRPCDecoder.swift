//
//  FastRPCDecoder.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 06/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

struct FastRPCDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T  where T: Decodable {
        return try _FastRPCDecoder(data: data).decode(type)
    }
}

class _FastRPCDecoder: Decoder, SingleValueDecodingContainer {

    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey : Any] = [:]

    private var data: Data

    // MARK: Initializers

    init(data: Data) {
        self.data = data
    }

    // MARK: Decoder

    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        fatalError()
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
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

    func decode(_ type: Bool.Type) throws -> Bool {
        let bool = try expectNonNull(type, with: .bool)

        // The bool value is encoded in the last bit
        return bool & 0x01 == 1
    }

    func decode(_ type: String.Type) throws -> String {
        let info = try expectNonNull(type, with: .string)

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
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Given data cannot be decoded using UTF8."))
        }

        return string
    }

    func decode(_ type: Int.Type) throws -> Int {
        // Check first for type information (without last 3 additional info bits)
        guard let type = data.first.map({ Int($0) & 0xF8 }) else {
            throw DecodingError.valueNotFound(Int.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected either Int8p, Int8n or Int type metadata, got null value instead."))
        }

        // Switch over int identifier
        switch type {
        case FastRPCObejectType.int8p.identifier: return try decodePositiveInteger()
        case FastRPCObejectType.int8n.identifier: return try decodeNegativeInteger()
        case FastRPCObejectType.int.identifier: return try decodeZigZagInteger()
        default:
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(Int.self) type but got \(type) type identifier instead."))
        }
    }

    func decode(_ type: Double.Type) throws -> Double {
        try expectNonNull(Double.self, with: .double)

        // Get double data (fixed size for IEEE 754)
        let bytes = try expectBytes(count: 8)

        // Convert raw data into double
        return bytes.withUnsafeBytes { $0.pointee }
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try T(from: self)
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

    // MARK: Internal Encoding

    private func decodePositiveInteger() throws -> Int {
        let info = try expectNonNull(Int.self, with: .int8p)
        // Encode int size and increase it by 1 (FRPC standard)
        let dataSize = Int(info) + 1
        // Get expected bytes
        let bytes = try expectBytes(count: dataSize)

        // Return converted bytes
        return Int(data: bytes)
    }

    private func decodeNegativeInteger() throws -> Int {
        let info = try expectNonNull(Int.self, with: .int8n)
        // Encode int size and increase it by 1 (FRPC standard)
        let dataSize = Int(info) + 1
        // Get expected bytes
        let bytes = try expectBytes(count: dataSize)
        // Convert data to integer
        let int = Int(data: bytes)

        return -int
    }

    private func decodeZigZagInteger() throws -> Int {
        fatalError("ZigZag integer decoding is not implemented yet. Use Int8p or Int8n instead.")
    }

    private func decode(_ type: Data.Type) throws -> Data {
        fatalError()
    }

    private func decode(_ type: Date.Type) throws -> Date {
        fatalError()
    }

    // MARK: Private API

    /// Requires data to not be null or has null literal. On success, returns additional type info
    /// for given type.
    @discardableResult
    private func expectNonNull<T>(_ type: T.Type, with objectType: FastRPCObejectType) throws -> UInt8 {
        // Do not allow null values on stack
        guard !self.decodeNil() else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(type) but found null value instead."))
        }

        guard
            let byte = data.first,
            // Compare actual type with required type (mask off last three bits)
            objectType.identifier == byte & 0xF8
            else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Expected type information for \(type) (\(objectType.identifier) but got null value or incorrect information instead."))
        }

        // We have requested type byte, remove it
        _ = data.popFirst()

        // Return aditional type info (last three bits)
        return byte & 0x07
    }

    private func expectBytes(count: Int) throws -> Data {
        // Check if we have required bytes count
        guard data.count >= count else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(count)B of data, got \(data.count)B instead."))
        }

        // Get expected bytes and remove it
        let bytes = data.prefix(count)
        data.removeFirst(count)

        return bytes
    }

    private func fallbackImplementationNotice<T, U>(from required: T.Type, to fallback: U.Type) where U: Decodable {
        debugPrint("[FastFRPCSwift] Required type \(required) is not supported by FastRPC standard. The value will be decoded as \(fallback) which may cause undefined behavior.")
    }
}
