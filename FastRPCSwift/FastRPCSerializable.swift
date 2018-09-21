//
//  FastRPCSerializable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Object which is able to be serialized through FastRPC protocol.
protocol FastRPCSerializable {
    /// Returns raw data representing object in FastRPC protocol.
    /// Throws FastRPC error if object is not serializable.
    ///
    /// - Returns: Raw data representing structure
    /// - Throws: FastRPCError on failure
    func serialize() throws -> Data
}

public final class KeyedSerializationContainer<T: CodingKey> {
    // MARK: Properties
    
    private let serializationContainer: SerializationContainer

    private weak var buffer: SerializationBuffer?

    // MARK: Initializers

    init(buffer: SerializationBuffer) {
        self.serializationContainer = SerializationContainer(buffer: buffer)
        self.buffer = buffer
    }

    // MARK: Primitives

    func serialize(bool: Bool, for key: T) {
        serializationContainer.serialize(bool: bool, for: key.stringValue)
    }

    func serialize(int: Int, for key: T) {
        serializationContainer.serialize(int: int, for: key.stringValue)
    }

    func serialize(string: String, for key: T) {
        serializationContainer.serialize(string: string, for: key.stringValue)
    }

    // MARK: Objects

//    func serialize(object: PublicFastFRPCSerializable, for key: T) {
//        serializationContainer.serialize(object: object, for: key.stringValue)
//    }

    // MARK: Collections

    func serialize(collection: [Bool], for key: T) {
        serializationContainer.serialize(collection: collection, for: key.stringValue)
    }

    func serialize(collection: [Int], for key: T) {
        serializationContainer.serialize(collection: collection, for: key.stringValue)
    }

    func serialize(collection: String, for key: T) {
        serializationContainer.serialize(collection: collection, for: key.stringValue)
    }
}

//protocol PublicFastFRPCSerializable {
//    func serialize(into buffer: SerializationBuffer)
//}
//
//struct TheirStruct: Codable, PublicFastFRPCSerializable {
//    var gest: Bool
//    var cest: [Int]
//
//    func serialize(into buffer: SerializationBuffer) {
//        let container = buffer.container(for: CodingKeys.self)
//
//        container.serialize(bool: gest, for: .gest)
//        container.serialize(collection: cest, for: .cest)
//    }
//}
//
//struct MyStruct: Codable, PublicFastFRPCSerializable {
//    var test: String
//    var best: Int
//    var their: TheirStruct
//
//    func serialize(into buffer: SerializationBuffer) {
//        let container = buffer.container(for: CodingKeys.self)
//
//        container.serialize(string: test, for: .test)
//        container.serialize(int: best, for: .best)
//        container.serialize(object: their, for: .their)
//    }
//}
