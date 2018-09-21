//
//  KeyedSerializationContainer.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 21/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Keyed serialization container wraps standard `SerializationContainer` by adding
/// compile-time safe API using Swift 4 Codable support.
public class KeyedSerializationContainer<T: CodingKey> {
    // MARK: - Properties

    /// Underlying untyped serialization container.
    private let serializationContainer: SerializationContainer

    // MARK: - Initializers

    /// Public initializer for creating serialization container. Creates new empty container.
    public init(for keys: T.Type) {
        self.serializationContainer = SerializationContainer()
    }

    // MARK: Public API

    /// See `SerializationContainer.createBuffer()`
    public func createBuffer() -> SerializationBuffer {
        return serializationContainer.createBuffer()
    }

    // MARK: - Primitives

    /// See `SerializationContainer.serialize(bool:for:)`
    public func serialize(bool: Bool, for key: T) throws {
        try serializationContainer.serialize(bool: bool, for: key.stringValue)
    }

    /// See `SerializationContainer.serialize(int:for:)`
    public func serialize(int: Int, for key: T) throws {
        try serializationContainer.serialize(int: int, for: key.stringValue)
    }

    /// See `SerializationContainer.serialize(string:for:)`
    public func serialize(string: String, for key: T) throws {
        try serializationContainer.serialize(string: string, for: key.stringValue)
    }

    // MARK: - Objects

    // MARK: Collections

    /// See `SerializationContainer.serialize(collection:for:)`
    public func serialize(collection: [Bool], for key: T) throws {
        try serializationContainer.serialize(collection: collection, for: key.stringValue)
    }

    /// See `SerializationContainer.serialize(collection:for:)`
    public func serialize(collection: [Int], for key: T) throws {
        try serializationContainer.serialize(collection: collection, for: key.stringValue)
    }


    /// See `SerializationContainer.serialize(collection:for:)`
    public func serialize(collection: [String], for key: T) throws {
        try serializationContainer.serialize(collection: collection, for: key.stringValue)
    }
}
