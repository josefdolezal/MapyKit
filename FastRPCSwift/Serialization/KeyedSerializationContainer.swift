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

    /// See `SerializationContainer.serialize(value:for:)`
    public func serialize(value: FastRPCSerializable, for key: T) throws {
        try serializationContainer.serialize(value: value, for: key.stringValue)
    }
}
