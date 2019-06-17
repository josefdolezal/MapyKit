//
//  FastRPCDecoder.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 06/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

public struct FastRPCDecoder {
    // MARK: Initializers

    public init() { }

    // MARK: Public API

    public func decodeResponse<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        let response = try FastRPCSerialization.frpcResponse(with: data)

        return try _FastRPCDecoder(container: response, at: [])
            .decode(type)
    }

    public func decodeProcedure<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        let procedure = try FastRPCSerialization.frpcProcedure(with: data)

        return try _FastRPCDecoder(container: procedure, at: [])
            .decode(type)
    }

    public func decodeFault<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        let fault = try FastRPCSerialization.frpcFault(with: data)

        return try _FastRPCDecoder(container: fault, at: [])
            .decode(type)
    }
}

class _FastRPCDecoder: Decoder, SingleValueDecodingContainer {
    // MARK: Properties

    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey : Any] = [:]

    private var container: Any

    // MARK: Initializers

    init(container: Any, at codingPath: [CodingKey]) {
        self.container = container
        self.codingPath = codingPath
    }

    // MARK: Decoder

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        guard let container = container as? NSDictionary else {
            throw FastRPCDecodingError.typeMismatch(expected: [String: Any].self, actual: self.container)
        }

        let keyedContainer = FRPCKeyedDecodingContainer<Key>(decoder: self, container: container)

        return KeyedDecodingContainer(keyedContainer)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard let container = container as? NSArray else {
            throw FastRPCDecodingError.typeMismatch(expected: [Any].self, actual: self.container)
        }

        return FRPCUnkeyedDecodingContainer(decoder: self, container: container)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }

    // MARK: SingleValueDecodingContainer

    func decodeNil() -> Bool {
        return container is NSNull
    }

    func decode(_ type: Bool.Type)   throws -> Bool   { return try cast(type) }
    func decode(_ type: String.Type) throws -> String { return try cast(type) }
    func decode(_ type: Int.Type)    throws -> Int    { return try cast(type) }
    func decode(_ type: Double.Type) throws -> Double { return try cast(type) }

    func decode(_ type: Float.Type)  throws -> Float  { return try type.init(cast(Double.self)) }
    func decode(_ type: Int8.Type)   throws -> Int8   { return try type.init(cast(Int.self)) }
    func decode(_ type: Int16.Type)  throws -> Int16  { return try type.init(cast(Int.self)) }
    func decode(_ type: Int32.Type)  throws -> Int32  { return try type.init(cast(Int.self)) }
    func decode(_ type: Int64.Type)  throws -> Int64  { return try type.init(cast(Int.self)) }
    func decode(_ type: UInt.Type)   throws -> UInt   { return try type.init(cast(Int.self)) }
    func decode(_ type: UInt8.Type)  throws -> UInt8  { return try type.init(cast(Int.self)) }
    func decode(_ type: UInt16.Type) throws -> UInt16 { return try type.init(cast(Int.self)) }
    func decode(_ type: UInt32.Type) throws -> UInt32 { return try type.init(cast(Int.self)) }
    func decode(_ type: UInt64.Type) throws -> UInt64 { return try type.init(cast(Int.self)) }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        // In addition to standard decodable types, we know how to unbox
        // Date and Data types
        switch type {
        case is Date.Type:
            return try cast(Date.self) as! T
        case is Data.Type:
            return try cast(Data.self) as! T
        default:
            // We don't know how to unbox this type, fallback to it's initializer
            return try T(from: self)
        }
    }

    // MARK: Private API

    private func cast<T>(_ type: T.Type) throws -> T {
        guard let value = container as? T else {
            throw FastRPCDecodingError.typeMismatch(expected: type, actual: container)
        }

        return value
    }

    private class FRPCUnkeyedDecodingContainer: UnkeyedDecodingContainer {
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
        private let container: NSArray

        // MARK: Initializers

        init(decoder: _FastRPCDecoder, container: NSArray) {
            self.decoder = decoder
            self.container = container
            self.currentIndex = 0
        }

        // MARK: Super decoder

        func superDecoder() throws -> Decoder {
            guard !isAtEnd else {
                throw FastRPCDecodingError.containerIsAtEnd
            }

            currentIndex += 1

            return _FastRPCDecoder(container: container[currentIndex], at: codingPath)
        }

        // MARK: Known types

        func decodeNil() throws -> Bool {
            guard !isAtEnd else {
                throw FastRPCDecodingError.containerIsAtEnd
            }

            if self.container[currentIndex] is NSNull {
                currentIndex += 1
                return true
            }

            return false
        }

        func decode(_ type: Bool.Type)   throws -> Bool   { return try cast(type) }
        func decode(_ type: String.Type) throws -> String { return try cast(type) }
        func decode(_ type: Double.Type) throws -> Double { return try cast(type) }
        func decode(_ type: Int.Type)    throws -> Int    { return try cast(type) }

        func decode(_ type: Float.Type)  throws -> Float  { return try type.init(cast(Double.self)) }
        func decode(_ type: Int8.Type)   throws -> Int8   { return try type.init(cast(Int.self)) }
        func decode(_ type: Int16.Type)  throws -> Int16  { return try type.init(cast(Int.self)) }
        func decode(_ type: Int32.Type)  throws -> Int32  { return try type.init(cast(Int.self)) }
        func decode(_ type: Int64.Type)  throws -> Int64  { return try type.init(cast(Int.self)) }
        func decode(_ type: UInt.Type)   throws -> UInt   { return try type.init(cast(Int.self)) }
        func decode(_ type: UInt8.Type)  throws -> UInt8  { return try type.init(cast(Int.self)) }
        func decode(_ type: UInt16.Type) throws -> UInt16 { return try type.init(cast(Int.self)) }
        func decode(_ type: UInt32.Type) throws -> UInt32 { return try type.init(cast(Int.self)) }
        func decode(_ type: UInt64.Type) throws -> UInt64 { return try type.init(cast(Int.self)) }

        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            switch type {
            case is Date.Type:
                return try cast(Date.self) as! T
            case is Data.Type:
                return try cast(Data.self) as! T
            default:
                guard !isAtEnd else {
                    throw FastRPCDecodingError.containerIsAtEnd
                }

                let nestedDecoder = _FastRPCDecoder(container: container[currentIndex], at: decoder.codingPath)
                let value = try T(from: nestedDecoder)

                currentIndex += 1

                return value
            }
        }

        // MARK: Nested containers

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            guard !isAtEnd else {
                throw FastRPCDecodingError.containerIsAtEnd
            }

            guard let container = self.container[currentIndex] as? NSDictionary else {
                throw FastRPCDecodingError.typeMismatch(expected: NSDictionary.self, actual: self.container[currentIndex])
            }

            currentIndex += 1

            return KeyedDecodingContainer(FRPCKeyedDecodingContainer<NestedKey>(decoder: decoder, container: container))
        }

        func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            guard !isAtEnd else {
                throw FastRPCDecodingError.containerIsAtEnd
            }

            guard let container = self.container[currentIndex] as? NSArray else {
                throw FastRPCDecodingError.typeMismatch(expected: NSArray.self, actual: self.container[currentIndex])
            }

            currentIndex += 1

            return FRPCUnkeyedDecodingContainer(decoder: decoder, container: container)
        }

        // MARK: Private API

        private func cast<T>(_ type: T.Type) throws -> T {
            guard !isAtEnd else {
                throw FastRPCDecodingError.containerIsAtEnd
            }

            guard let value = container[currentIndex] as? T else {
                throw FastRPCDecodingError.typeMismatch(expected: type, actual: container[currentIndex])
            }

            currentIndex += 1

            return value
        }
    }

    private class FRPCKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
        // MARK: Properties

        var allKeys: [Key] {
            return container.allKeys
                .compactMap { $0 as? String }
                .compactMap { Key(stringValue: $0) }
        }

        var codingPath: [CodingKey] {
            return decoder.codingPath
        }

        private let container: NSDictionary
        private let decoder: _FastRPCDecoder

        // MARK: Initializers

        init(decoder: _FastRPCDecoder, container: NSDictionary) {
            self.decoder = decoder
            self.container = container
        }

        // MARK: Superclass decoders

        func superDecoder() throws -> Decoder {
            return _FastRPCDecoder(container: container, at: codingPath)
        }

        func superDecoder(forKey key: Key) throws -> Decoder {
            decoder.codingPath.append(key)
            defer { _ = decoder.codingPath.popLast() }

            let value = container[key.stringValue] ?? NSNull()

            return _FastRPCDecoder(container: value, at: decoder.codingPath)
        }

        // MARK: Meta

        func contains(_ key: Key) -> Bool {
            return container[key.stringValue] != nil
        }

        // MARK: Nested containers

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            decoder.codingPath.append(key)
            defer { _ = decoder.codingPath.popLast() }

            guard let value = container[key.stringValue] else {
                throw FastRPCDecodingError.keyNotFound(key)
            }

            guard let nestedContainer = value as? NSDictionary else {
                throw FastRPCDecodingError.typeMismatch(expected: NSDictionary.self, actual: value)
            }

            let keyedContainer = FRPCKeyedDecodingContainer<NestedKey>(decoder: decoder, container: nestedContainer)
            return KeyedDecodingContainer(keyedContainer)
        }

        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            decoder.codingPath.append(key)
            defer { _ = decoder.codingPath.popLast() }

            guard let value = container[key.stringValue] else {
                throw FastRPCDecodingError.keyNotFound(key)
            }

            guard let nestedContainer = value as? NSArray else {
                throw FastRPCDecodingError.typeMismatch(expected: NSDictionary.self, actual: value)
            }

            return FRPCUnkeyedDecodingContainer(decoder: decoder, container: nestedContainer)
        }

        // MARK: Decoders

        func decodeNil(forKey key: Key) throws -> Bool {
            guard let value = container[key.stringValue] else {
                throw FastRPCDecodingError.keyNotFound(key)
            }

            return value is NSNull
        }

        func decode(_ type: Bool.Type, forKey key: Key)   throws -> Bool   { return try cast(type, forKey: key) }
        func decode(_ type: String.Type, forKey key: Key) throws -> String { return try cast(type, forKey: key) }
        func decode(_ type: Double.Type, forKey key: Key) throws -> Double { return try cast(type, forKey: key) }
        func decode(_ type: Int.Type, forKey key: Key)    throws -> Int    { return try cast(type, forKey: key) }

        func decode(_ type: Float.Type, forKey key: Key)  throws -> Float  { return try type.init(cast(Double.self, forKey: key)) }
        func decode(_ type: Int8.Type, forKey key: Key)   throws -> Int8   { return try type.init(cast(Int.self, forKey: key)) }
        func decode(_ type: Int16.Type, forKey key: Key)  throws -> Int16  { return try type.init(cast(Int.self, forKey: key)) }
        func decode(_ type: Int32.Type, forKey key: Key)  throws -> Int32  { return try type.init(cast(Int.self, forKey: key)) }
        func decode(_ type: Int64.Type, forKey key: Key)  throws -> Int64  { return try type.init(cast(Int.self, forKey: key)) }
        func decode(_ type: UInt.Type, forKey key: Key)   throws -> UInt   { return try type.init(cast(Int.self, forKey: key)) }
        func decode(_ type: UInt8.Type, forKey key: Key)  throws -> UInt8  { return try type.init(cast(Int.self, forKey: key)) }
        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { return try type.init(cast(Int.self, forKey: key)) }
        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { return try type.init(cast(Int.self, forKey: key)) }
        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { return try type.init(cast(Int.self, forKey: key)) }

        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
            switch type {
            case is Date.Type:
                return try cast(Date.self, forKey: key) as! T
            case is Data.Type:
                return try cast(Data.self, forKey: key) as! T
            default:
                guard let value = container[key.stringValue] else {
                    throw FastRPCDecodingError.keyNotFound(key)
                }

                decoder.codingPath.append(key)
                defer { _ = decoder.codingPath.popLast() }

                let nestedDecoder = _FastRPCDecoder(container: value, at: decoder.codingPath)

                return try T(from: nestedDecoder)
            }
        }

        // MARK: Private API

        private func cast<T>(_ type: T.Type, forKey key: Key) throws -> T {
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
    }
}
