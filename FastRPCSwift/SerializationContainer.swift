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

    public func createBuffer() -> SerializationBuffer {
        // Serialize data by merging members data
        let serializedData = members.reduce(Data(), +)

        return SerializationBuffer(data: serializedData)
    }

    // MARK: - Primitives

    public func serialize(bool: Bool, for key: String) throws {

    }

    public func serialize(int: Int, for key: String) throws {

    }

    public func serialize(string: String, for key: String) throws {

    }

    // MARK: - Objects

    // MARK: Collections

    public func serialize(collection: [Bool], for key: String) throws {

    }

    public func serialize(collection: [Int], for key: String) throws {

    }

    public func serialize(collection: [String], for key: String) throws {

    }
}
