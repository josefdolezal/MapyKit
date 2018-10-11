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

        return try _FastRPCDecoder(container: object).decode(type)
    }
}

class _FastRPCDecoder: Decoder, SingleValueDecodingContainer {
    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey : Any] = [:]

    private var container: Any

    // MARK: Initializers

    init(container: Any) {
        self.container = container
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
