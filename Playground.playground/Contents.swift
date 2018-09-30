
@testable import FastRPCSwift

struct FastRPCDecoder {
    public func decode<T: Decodable>(_ value: T.Type, from data: Data) throws -> T {
        let decoder = _FastRPCDecoder(data: data)

        return try T(from: decoder)
    }
}

struct _FastRPCDecoder: Decoder, SingleValueDecodingContainer {
    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey : Any] = [:]

    private var data: Data

    init(data: Data) {
        self.data = data
    }

    // MARK: - Decoder

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        fatalError()
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        fatalError()
    }

    // MARK: SingleValueDecodingContainer

    func decodeNil() -> Bool {
        // We decode nil only if first byte is nil literal
        guard let byte = data.first else {
            return false
        }

        return byte == UInt8(FastRPCObejectType.nil.identifier)
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        try expectNonNull(type)

        let bool = data.popFirst()!

        // The bool value is encoded in the last bit
        return bool & 1 == 1
    }

    func decode(_ type: String.Type) throws -> String {
        try expectNonNull(type)

        
    }

    func decode(_ type: Double.Type) throws -> Double {
        fatalError()
    }

    func decode(_ type: Float.Type) throws -> Float {
        fatalError()
    }

    func decode(_ type: Int.Type) throws -> Int {
        fatalError()
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        fatalError()
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        fatalError()
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        fatalError()
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        fatalError()
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        fatalError()
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        fatalError()
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        fatalError()
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        fatalError()
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        fatalError()
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        fatalError()
    }

    // MARK: Private API

    private func expectNonNull<T>(_ type: T.Type) throws {
        guard !self.decodeNil() else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected \(type) but found null value instead."))
        }
    }
}
