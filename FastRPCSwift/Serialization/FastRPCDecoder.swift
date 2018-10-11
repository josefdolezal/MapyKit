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

    func decode(_ type: Bool.Type) throws -> Bool {
        guard let bool = container as? Bool else {
            throw typeMismatchError(expcted: type, butGot: container)
        }

        return bool
    }

    func decode(_ type: String.Type) throws -> String {
        guard let string = container as? String else {
            throw typeMismatchError(expcted: type, butGot: container)
        }

        return string
    }

    func decode(_ type: Int.Type) throws -> Int {
        guard let int = container as? Int else {
            throw typeMismatchError(expcted: type, butGot: container)
        }

        return int
    }

    func decode(_ type: Double.Type) throws -> Double {
        guard let double = container as? Double else {
            throw typeMismatchError(expcted: type, butGot: container)
        }

        return double
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        switch type {
        case Date.self:
            return try decode(type)
        case Data.self:
            return try decode(type)
        default:
            return try T(from: self)
        }

        return try T(from: self)
    }

    // MARK: SingleValueDecodingContainer (Unsupported types)

    func decode(_ type: Float.Type) throws -> Float { fatalError() }
    func decode(_ type: Int8.Type)  throws -> Int8 { fatalError() }
    func decode(_ type: Int16.Type) throws -> Int16 { fatalError() }
    func decode(_ type: Int32.Type) throws -> Int32 { fatalError() }
    func decode(_ type: Int64.Type) throws -> Int64 { fatalError() }
    func decode(_ type: UInt.Type) throws -> UInt { fatalError() }
    func decode(_ type: UInt8.Type) throws -> UInt8 { fatalError() }
    func decode(_ type: UInt16.Type) throws -> UInt16 { fatalError() }
    func decode(_ type: UInt32.Type) throws -> UInt32 { fatalError() }
    func decode(_ type: UInt64.Type) throws -> UInt64 { fatalError() }

    // MARK: Internal Encoding

    private func decode(_ type: Data.Type) throws -> Data {
        fatalError()
    }

    private func decode(_ type: Date.Type) throws -> Date {
        fatalError()
    }

    // MARK: Private API

    private func typeMismatchError<Expected, Actual>(expcted: Expected.Type, butGot actual: Actual) -> DecodingError {
        return DecodingError.typeMismatch(expcted, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected type \(expcted) but got \(type(of: actual)) instead."))
    }
}
