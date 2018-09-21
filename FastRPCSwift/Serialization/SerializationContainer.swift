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
        // Serialize data by merging members data
        let serializedData = members.reduce(Data(), +)

        return SerializationBuffer(data: serializedData)
    }

    // MARK: - Primitives

    /// Serialize Bool value into buffer under given key.
    ///
    /// - Parameters:
    ///   - bool: The value to be serialized
    ///   - key: Serialization key
    /// - Throws: FastRPCError
    public func serialize(bool: Bool, for key: String) throws {

    }

    /// Serialize Int value into buffer under given key.
    ///
    /// - Parameters:
    ///   - int: The value to be serialized
    ///   - key: Serialization key
    /// - Throws: FastRPCError
    public func serialize(int: Int, for key: String) throws {

    }

    /// Serialize String value into buffer under given key.
    ///
    /// - Parameters:
    ///   - string: The value to be serialized
    ///   - key: Serialization key
    /// - Throws: FastRPCError
    public func serialize(string: String, for key: String) throws {

    }

    // MARK: - Objects

    // MARK: Collections

    /// Serialize collection of primitive values into buffer under given key.
    ///
    /// - Parameters:
    ///   - collection: The collection to be serialized
    ///   - key: Serialization key
    /// - Throws: FastRPCError
    public func serialize(collection: [Bool], for key: String) throws {

    }

    /// Serialize collection of primitive values into buffer under given key.
    ///
    /// - Parameters:
    ///   - collection: The collection to be serialized
    ///   - key: Serialization key
    /// - Throws: FastRPCError
    public func serialize(collection: [Int], for key: String) throws {

    }

    /// Serialize collection of primitive values into buffer under given key.
    ///
    /// - Parameters:
    ///   - collection: The collection to be serialized
    ///   - key: Serialization key
    /// - Throws: FastRPCError
    public func serialize(collection: [String], for key: String) throws {

    }
}
