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
        let object = try FastRPCSerialization.object(with: data)

        return try _FastRPCDecoder(container: object, at: []).decode(type)
    }
}

class _FastRPCDecoder: Decoder, SingleValueDecodingContainer {
    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey : Any] = [:]

    private var container: Any

    // MARK: Initializers

    init(container: Any, at codingPath: [CodingKey]) {
        self.container = container
        self.codingPath = codingPath
    }

    // MARK: Decoder

    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        guard let nestedContainer = container as? [String: Any] else {
            throw FastRPCDecodingError.typeMismatch(expected: [String: Any].self, actual: container)
        }

        let keyedContainer = FRPCKeyedDecodingContainer<Key>(decoder: self, container: nestedContainer)

        return KeyedDecodingContainer(keyedContainer)
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }

    // MARK: SingleValueDecodingContainer (Primitives)

    func decodeNil() -> Bool {
        return container is NSNull
    }

    func decode(_ type: Bool.Type)   throws -> Bool   { return try unbox(type) }
    func decode(_ type: String.Type) throws -> String { return try unbox(type) }
    func decode(_ type: Int.Type)    throws -> Int    { return try unbox(type) }
    func decode(_ type: Double.Type) throws -> Double { return try unbox(type) }
    func decode(_ type: Data.Type)   throws -> Data   { return try unbox(type) }
    func decode(_ type: Date.Type)   throws -> Date   { return try unbox(type) }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        switch type {
        case is Date.Type:
            return try decode(Date.self) as! T
        case is Data.Type:
            return try decode(Data.self) as! T
        default:
            return try T(from: self)
        }
    }

    // MARK: SingleValueDecodingContainer (Unsupported types)

    func decode(_ type: Float.Type)  throws -> Float  { fatalError() }
    func decode(_ type: Int8.Type)   throws -> Int8   { fatalError() }
    func decode(_ type: Int16.Type)  throws -> Int16  { fatalError() }
    func decode(_ type: Int32.Type)  throws -> Int32  { fatalError() }
    func decode(_ type: Int64.Type)  throws -> Int64  { fatalError() }
    func decode(_ type: UInt.Type)   throws -> UInt   { fatalError() }
    func decode(_ type: UInt8.Type)  throws -> UInt8  { fatalError() }
    func decode(_ type: UInt16.Type) throws -> UInt16 { fatalError() }
    func decode(_ type: UInt32.Type) throws -> UInt32 { fatalError() }
    func decode(_ type: UInt64.Type) throws -> UInt64 { fatalError() }

    // MARK: Private API

    private func unbox<T>(_ type: T.Type) throws -> T {
        guard let value = container as? T else {
            throw typeMismatchError(expcted: type, butGot: container)
        }

        return value
    }

    private func typeMismatchError<Expected, Actual>(expcted: Expected.Type, butGot actual: Actual) -> DecodingError {
        return DecodingError.typeMismatch(expcted, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected type \(expcted) but got \(type(of: actual)) instead."))
    }
}

// MARK: - FRPCKeyedDecodingContainer

fileprivate struct FRPCKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    // MARK: Properties

    var allKeys: [Key] {
        return container.keys.compactMap { Key(stringValue: $0) }
    }

    private(set) var codingPath: [CodingKey]

    private let container: [String: Any]
    private let decoder: _FastRPCDecoder

    // MARK: Initializers

    init(decoder: _FastRPCDecoder, container: [String: Any]) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
    }

    // MARK: Super decoder

    func superDecoder() throws -> Decoder {
        return _FastRPCDecoder(container: container, at: codingPath)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        decoder.codingPath.append(key)
        defer { _ = decoder.codingPath.popLast() }

        let value = container[key.stringValue] ?? NSNull()

        return _FastRPCDecoder(container: value, at: decoder.codingPath)
    }

    // MARK: Known types

    func contains(_ key: Key) -> Bool {
        return container[key.stringValue] != nil
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        guard let value = container[key.stringValue] else {
            throw FastRPCDecodingError.keyNotFound(key)
        }

        return value is NSNull
    }

    func decode(_ type: Bool.Type, forKey key: Key)   throws -> Bool   { return try unbox(type, forKey: key) }
    func decode(_ type: String.Type, forKey key: Key) throws -> String { return try unbox(type, forKey: key) }
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double { return try unbox(type, forKey: key) }
    func decode(_ type: Int.Type, forKey key: Key)    throws -> Int    { return try unbox(type, forKey: key) }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        guard let value = container[key.stringValue] else {
            throw FastRPCDecodingError.keyNotFound(key)
        }

        decoder.codingPath.append(key)
        defer { _ = decoder.codingPath.popLast() }

        let nestedDecoder = _FastRPCDecoder(container: value, at: decoder.codingPath)

        return try T(from: nestedDecoder)
    }

    // MARK: Nested containers

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        decoder.codingPath.append(key)
        defer { _ = decoder.codingPath.popLast() }

        guard let value = container[key.stringValue] else {
            throw FastRPCDecodingError.keyNotFound(key)
        }

        guard let nestedContainer = value as? [String: Any] else {
            throw FastRPCDecodingError.typeMismatch(expected: [String: Any].self, actual: value)
        }

        let keyedContainer = FRPCKeyedDecodingContainer<NestedKey>(decoder: decoder, container: nestedContainer)
        return KeyedDecodingContainer(keyedContainer)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    // MARK: Unsupported types

    func decode(_ type: Int8.Type, forKey key: Key)   throws -> Int8   { throw unsupportedTypeError(Int8.self, replacement: Int.self) }
    func decode(_ type: Int16.Type, forKey key: Key)  throws -> Int16  { throw unsupportedTypeError(Int16.self, replacement: Int.self) }
    func decode(_ type: Int32.Type, forKey key: Key)  throws -> Int32  { throw unsupportedTypeError(Int32.self, replacement: Int.self) }
    func decode(_ type: Int64.Type, forKey key: Key)  throws -> Int64  { throw unsupportedTypeError(Int64.self, replacement: Int.self) }
    func decode(_ type: UInt.Type, forKey key: Key)   throws -> UInt   { throw unsupportedTypeError(UInt.self, replacement: Int.self) }
    func decode(_ type: UInt8.Type, forKey key: Key)  throws -> UInt8  { throw unsupportedTypeError(UInt8.self, replacement: Int.self) }
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { throw unsupportedTypeError(UInt16.self, replacement: Int.self) }
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { throw unsupportedTypeError(UInt32.self, replacement: Int.self) }
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { throw unsupportedTypeError(UInt64.self, replacement: Int.self) }
    func decode(_ type: Float.Type, forKey key: Key)  throws -> Float  { throw unsupportedTypeError(UInt64.self, replacement: Float.self) }

    // MARK: Private API

    private func unbox<T>(_ type: T.Type, forKey key: Key) throws -> T {
        // Try to lookup the value inside container
        guard let value = container[key.stringValue] else {
            throw FastRPCDecodingError.keyNotFound(key)
        }

        // We found a value, update coding path
        decoder.codingPath.append(key)
        defer { _ = decoder.codingPath.popLast() }

        // Cast found value to expected type
        guard let t = value as? T else {
            throw FastRPCDecodingError.typeMismatch(expected: type, actual: value)
        }

        return t
    }

    private func unsupportedTypeError<A, R>(_ type: A.Type, replacement: R.Type) -> FastRPCDecodingError {
        return FastRPCDecodingError.unsupportedType(type, replacement: replacement)
    }
}

fileprivate struct FRPCUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    // MARK: Properties

    var codingPath: [CodingKey] {
        return decoder.codingPath
    }

    var count: Int? {
        return container.count
    }

    var isAtEnd: Bool {
        return currentIndex >= container.count
    }

    private(set) var currentIndex: Int

    private let decoder: _FastRPCDecoder
    private let container: [Any]

    // MARK: Initializers

    init(decoder: _FastRPCDecoder, container: [Any]) {
        self.decoder = decoder
        self.container = container
        self.currentIndex = 0
    }

    // MARK: Super decoder

    mutating func superDecoder() throws -> Decoder {
        return _FastRPCDecoder(container: container[currentIndex], at: codingPath)
    }

    // MARK: Known types

    mutating func decodeNil() throws -> Bool {
        guard !isAtEnd else {
            throw FastRPCDecodingError.containerIsAtEnd
        }

        if self.container[currentIndex] is NSNull {
            currentIndex += 1
            return true
        }

        return false
    }

    mutating func decode(_ type: Bool.Type)   throws -> Bool   { return try unbox(type) }
    mutating func decode(_ type: String.Type) throws -> String { return try unbox(type) }
    mutating func decode(_ type: Double.Type) throws -> Double { return try unbox(type) }
    mutating func decode(_ type: Int.Type)    throws -> Int    { return try unbox(type) }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        guard !isAtEnd else {
            throw FastRPCDecodingError.containerIsAtEnd
        }

        let nestedDecoder = _FastRPCDecoder(container: container[currentIndex], at: decoder.codingPath)

        return try T(from: nestedDecoder)
    }

    // MARK: Nested containers

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        guard !isAtEnd else {
            throw FastRPCDecodingError.containerIsAtEnd
        }

        guard let container = self.container[currentIndex] as? [String: Any] else {
            throw FastRPCDecodingError.typeMismatch(expected: [String: Any].self, actual: self.container[currentIndex])
        }

        let nestedContainer = FRPCKeyedDecodingContainer<NestedKey>(decoder: decoder, container: container)

        return KeyedDecodingContainer(nestedContainer)
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard !isAtEnd else {
            throw FastRPCDecodingError.containerIsAtEnd
        }

        guard let container = self.container[currentIndex] as? [Any] else {
            throw FastRPCDecodingError.typeMismatch(expected: [Any].self, actual: self.container[currentIndex])
        }

        return FRPCUnkeyedDecodingContainer(decoder: decoder, container: container)
    }

    // MARK: Unsupported types

    mutating func decode(_ type: Int8.Type)   throws -> Int8   { throw unsupportedTypeError(Int8.self, replacement: Int.self) }
    mutating func decode(_ type: Int16.Type)  throws -> Int16  { throw unsupportedTypeError(Int16.self, replacement: Int.self) }
    mutating func decode(_ type: Int32.Type)  throws -> Int32  { throw unsupportedTypeError(Int32.self, replacement: Int.self) }
    mutating func decode(_ type: Int64.Type)  throws -> Int64  { throw unsupportedTypeError(Int64.self, replacement: Int.self) }
    mutating func decode(_ type: UInt.Type)   throws -> UInt   { throw unsupportedTypeError(UInt.self, replacement: Int.self) }
    mutating func decode(_ type: UInt8.Type)  throws -> UInt8  { throw unsupportedTypeError(UInt8.self, replacement: Int.self) }
    mutating func decode(_ type: UInt16.Type) throws -> UInt16 { throw unsupportedTypeError(UInt16.self, replacement: Int.self) }
    mutating func decode(_ type: UInt32.Type) throws -> UInt32 { throw unsupportedTypeError(UInt32.self, replacement: Int.self) }
    mutating func decode(_ type: UInt64.Type) throws -> UInt64 { throw unsupportedTypeError(UInt64.self, replacement: Int.self) }
    mutating func decode(_ type: Float.Type)  throws -> Float  { throw unsupportedTypeError(Float.self, replacement: Double.self) }

    // MARK: Private API

    private func unbox<T: Decodable>(_ type: T.Type) throws -> T {
        guard !isAtEnd else {
            throw FastRPCDecodingError.containerIsAtEnd
        }

        let nestedDecoder = _FastRPCDecoder(container: container[currentIndex], at: decoder.codingPath)

        return try T(from: nestedDecoder)
    }

    private func unsupportedTypeError<A, R>(_ actual: A.Type, replacement: R.Type) -> FastRPCDecodingError {
        return FastRPCDecodingError.unsupportedType(actual, replacement: replacement)
    }
}
