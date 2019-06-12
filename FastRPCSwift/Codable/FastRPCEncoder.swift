//
//  FastRPCEncoder.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 06/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

public struct FastRPCEncoder {
    // MARK: Initializers

    public init() { }

    // MARK: Public API

    public func encode(procedure: String) throws -> Data {
        return try FastRPCSerialization.data(procedure: procedure, arguments: [])
    }

    public func encode<T: Encodable>(procedure: String, _ arg1: T) throws -> Data {
        let encoder = _FastRPCEncoder()

        let _arg1 = try encoder.boxObject(arg1)

        return try FastRPCSerialization.data(procedure: procedure, arguments: [_arg1])
    }

    public func encode<T: Encodable, U: Encodable>(procedure: String, _ arg1: T, _ arg2: U) throws -> Data {
        let encoder = _FastRPCEncoder()

        let _arg1 = try encoder.boxObject(arg1)
        let _arg2 = try encoder.boxObject(arg2)

        return try FastRPCSerialization.data(procedure: procedure, arguments: [_arg1, _arg2])
    }

    public func encode(faultCode code: Int, message: String) throws -> Data {
        return try FastRPCSerialization.data(faultCode: code, message: message)
    }
}

public protocol FastRPCResponseEncodingContainer: SingleValueEncodingContainer { }

class _FastRPCEncoder: Encoder, SingleValueEncodingContainer {

    // MARK: Properties

    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]

    private var container: Any?

    // MARK: Container

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        // Do not allow multiple top-level encoding
        guard self.container == nil else {
            #warning("Throw an info message about encoding multiple top-level objects")
            fatalError()
        }

        // Create structure container
        let container = NSMutableDictionary()
        self.container = container

        fatalError()
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        // Do not allow multiple top-level encoding
        guard self.container == nil else {
            #warning("Throw an info message about encoding multiple top-level objects")
            fatalError()
        }

        // Create the collection container
        let container = NSMutableArray()
        self.container = container

        // Create the collection
        return FastRPCUnkeyedEncodingContainer(codingPath: codingPath, encoder: self, container: container)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        // Do not allow multiple top-level encoding
        guard self.container == nil else {
            #warning("Throw an info message about encoding multiple top-level objects")
            fatalError()
        }

        return self
    }

    // MARK: - Internal converting interface

    func boxObject<T: Encodable>(_ value: T) throws -> Any {
        // Encode the given top-level value into container
        try value.encode(to: self)

        guard let container = container else {
            #warning("Throw error informing that object T did not encode any value")
            fatalError()
        }

        return container
    }

    // MARK: - SingleValueEncodingContainer

    private func requireEmptyContainer() throws {
        if container != nil {
            #warning("Throw an error informing about unsuccessful encoding")
            fatalError()
        }
    }

    func encodeNil() throws {
        try requireEmptyContainer()
        container = NSNull()
    }

    func encode(_ value: Bool)   throws {
        try requireEmptyContainer()
        container = value
    }

    func encode(_ value: String) throws {
        try requireEmptyContainer()
        container = value
    }

    func encode(_ value: Double) throws {
        try requireEmptyContainer()
        container = value
    }

    func encode(_ value: Int)    throws {
        try requireEmptyContainer()
        container = value
    }

    func encode(_ value: Int8) throws {
        try requireEmptyContainer()
        container = Int(value)
    }

    func encode(_ value: Int16) throws {
        try requireEmptyContainer()
        container = Int(value)
    }

    func encode(_ value: Int32) throws {
        try requireEmptyContainer()
        container = Int(value)
    }

    func encode(_ value: Int64) throws {
        try requireEmptyContainer()
        container = Int(value)
    }

    func encode(_ value: UInt) throws {
        try requireEmptyContainer()
        container = Int(value)
    }

    func encode(_ value: UInt8) throws {
        try requireEmptyContainer()
        container = Int(value)
    }

    func encode(_ value: UInt16) throws {
        try requireEmptyContainer()
        container = Int(value)
    }

    func encode(_ value: UInt32) throws {
        try requireEmptyContainer()
        container = Int(value)
    }

    func encode(_ value: UInt64) throws {
        try requireEmptyContainer()
        container = Int(value)
    }

    func encode(_ value: Float) throws {
        try requireEmptyContainer()
        container = Double(value)
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        switch value {
        case let data as Data:
            container = data
        case let date as Date:
            container = date
        case let fault as Fault:
            container = fault
        default:
            #warning("Unclear how to handle this case (or value.encode(..))")
            container = try boxObject(value)
        }
    }

    // MARK: - UnkeyedEncodingContainer

    private class FastRPCUnkeyedEncodingContainer: UnkeyedEncodingContainer {
        // MARK: Properties
        var codingPath: [CodingKey]

        var count: Int {
            return container.count
        }

        private let encoder: _FastRPCEncoder
        private let container: NSMutableArray

        // MARK: Initializers

        init(codingPath: [CodingKey], encoder: _FastRPCEncoder, container: NSMutableArray) {
            self.codingPath = codingPath
            self.encoder = encoder
            self.container = container
        }

        // MARK: Encoding

        func encodeNil()             throws { container.add(NSNull()) }
        func encode(_ value: Bool)   throws { container.add(value) }
        func encode(_ value: String) throws { container.add(value) }
        func encode(_ value: Double) throws { container.add(value) }
        func encode(_ value: Float)  throws { container.add(Double(value)) }
        func encode(_ value: Int)    throws { container.add(value) }
        func encode(_ value: Int8)   throws { container.add(Int(value)) }
        func encode(_ value: Int16)  throws { container.add(Int(value)) }
        func encode(_ value: Int32)  throws { container.add(Int(value)) }
        func encode(_ value: Int64)  throws { container.add(Int(value)) }
        func encode(_ value: UInt)   throws { container.add(Int(value)) }
        func encode(_ value: UInt8)  throws { container.add(Int(value)) }
        func encode(_ value: UInt16) throws { container.add(Int(value)) }
        func encode(_ value: UInt32) throws { container.add(Int(value)) }
        func encode(_ value: UInt64) throws { container.add(Int(value)) }

        func encode<T>(_ value: T) throws where T : Encodable {
            switch value {
            case let data as Data:
                container.add(data)
            case let date as Date:
                container.add(date)
            case let fault as Fault:
                container.add(fault)
            default:
                #warning("Unclear how to handle this case (or value.encode(..))")
                container.add(try encoder.boxObject(value))
            }
        }

        // MARK: Container

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            let container = NSMutableDictionary()

            self.container.add(container)

            return KeyedEncodingContainer(FastRPCKeyedEncodingContainer<NestedKey>(encoder: encoder, container: container))
        }

        func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            let container = NSMutableArray()

            self.container.add(container)

            return FastRPCUnkeyedEncodingContainer(codingPath: codingPath, encoder: encoder, container: container)
        }

        func superEncoder() -> Encoder {
            #warning("Superclass encoder is not fully implemented yet")
            return encoder
        }
    }

    // MARK: - KeyedEncodingContainer

    private class FastRPCKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
        // MARK: Properties

        var codingPath: [CodingKey] = []

        private let encoder: _FastRPCEncoder
        private let container: NSMutableDictionary

        // MARK: Initializers

        init(encoder: _FastRPCEncoder, container: NSMutableDictionary) {
            self.container = container
            self.encoder = encoder
        }

        // MARK: Encoding

        func encodeNil(forKey key: Key)               throws { container[key.stringValue] = NSNull() }
        func encode(_ value: Bool, forKey key: Key)   throws { container[key.stringValue] = value }
        func encode(_ value: String, forKey key: Key) throws { container[key.stringValue] = value }
        func encode(_ value: Double, forKey key: Key) throws { container[key.stringValue] = value }
        func encode(_ value: Float, forKey key: Key)  throws { container[key.stringValue] = Double(value) }
        func encode(_ value: Int, forKey key: Key)    throws { container[key.stringValue] = value }
        func encode(_ value: Int8, forKey key: Key)   throws { container[key.stringValue] = Int(value) }
        func encode(_ value: Int16, forKey key: Key)  throws { container[key.stringValue] = Int(value) }
        func encode(_ value: Int32, forKey key: Key)  throws { container[key.stringValue] = Int(value) }
        func encode(_ value: Int64, forKey key: Key)  throws { container[key.stringValue] = Int(value) }
        func encode(_ value: UInt, forKey key: Key)   throws { container[key.stringValue] = Int(value) }
        func encode(_ value: UInt8, forKey key: Key)  throws { container[key.stringValue] = Int(value) }
        func encode(_ value: UInt16, forKey key: Key) throws { container[key.stringValue] = Int(value) }
        func encode(_ value: UInt32, forKey key: Key) throws { container[key.stringValue] = Int(value) }
        func encode(_ value: UInt64, forKey key: Key) throws { container[key.stringValue] = Int(value) }

        func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
            codingPath.append(key)
            defer { codingPath.removeLast() }

            switch value {
            case let data as Data:
                container[key.stringValue] = data
            case let date as Date:
                container[key.stringValue] = date
            case let fault as Fault:
                container[key.stringValue] = fault
            default:
                container[key.stringValue] = try encoder.boxObject(value)
            }
        }

        // MARK: Container

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            let container = NSMutableDictionary()

            codingPath.append(key)
            defer { codingPath.removeLast() }

            guard self.container[key.stringValue] == nil else {
                #warning("throw already encoded value")
                fatalError()
            }

            self.container[key.stringValue] = container

            return KeyedEncodingContainer(FastRPCKeyedEncodingContainer<NestedKey>(encoder: encoder, container: container))
        }

        func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            let container = NSMutableArray()

            codingPath.append(key)
            defer { codingPath.removeLast() }

            guard self.container[key.stringValue] == nil else {
                #warning("throw already encoded value")
                fatalError()
            }

            self.container[key.stringValue] = container

            return FastRPCUnkeyedEncodingContainer(codingPath: codingPath, encoder: encoder, container: container)
        }

        func superEncoder() -> Encoder {
            #warning("Superclass encoder is not fully implemented yet")
            return encoder
        }

        func superEncoder(forKey key: Key) -> Encoder {
            codingPath.append(key)
            defer { codingPath.removeLast() }

            #warning("Superclass encoder is not fully implemented yet")

            return encoder
        }
    }
}
