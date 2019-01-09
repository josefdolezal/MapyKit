//
//  FastRPCEncoder.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 06/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

fileprivate protocol Container: class {
    var data: Data { get }
}

fileprivate class SingleValueContainer: Container {
    // MARK: Properties

    let data: Data

    // MARK: Initializers

    init(data: Data) {
        self.data = data
    }
}

fileprivate class StructuredContainer: Container {
    // MARK: Properties

    var data: Data {
        return members
            .map { $0.data }
            .reduce(Data(), +)
    }

    private var members: [Container] = []

    // MARK: Public API

    func add(member: Container) {
        members.append(member)
    }

    func add(data: Data) {
        members.append(SingleValueContainer(data: data))
    }
}

fileprivate class CollectionContainer: Container {
    // MARK: Properties
    var data: Data {
        // Get the collection data identifier
        let identifier = FastRPCObejectType.array.identifier + max(0, members.count - 1)
        let membersData = members
            // Get data for each member
            .map { $0.data }
            // Combine data
            .reduce(Data(), +)
        // Combine identifier, members count and elements itself
        let combined = identifier.usedBytes + members.count.usedBytes + membersData

        return combined
    }

    private var members: [Container] = []

    // MARK: Public API

    func add(member: Container) {
        members.append(member)
    }
}

public struct FastRPCEncoder {
    // MARK: Initializers

    public init() { }

    // MARK: Public API

    public func encode<T: Encodable>(_ value: T) throws -> Data {
        let encoder = _FastRPCEncoder()

        try encoder.encode(value)

        return encoder.data
    }
}

class _FastRPCEncoder: Encoder, SingleValueEncodingContainer {
    // MARK: Properties

    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]

    var data: Data {
        return containers
            .map { $0.data }
            .reduce(Data(), +)
    }

    private var containers: [Container] = []

    // MARK: Container

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        fatalError()
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let container = CollectionContainer()

        self.containers.append(container)

        return FastRPCUnkeyedEncodingContainer(codingPath: codingPath, encoder: self, container: container)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }

    // MARK: - SingleValueEncodingContainer

    func encodeNil()             throws { try containers.append(boxNil()) }
    func encode(_ value: Bool)   throws { try containers.append(box(value)) }
    func encode(_ value: String) throws { try containers.append(box(value)) }
    func encode(_ value: Double) throws { try containers.append(box(value)) }
    func encode(_ value: Int)    throws { try containers.append(box(value)) }
    func encode(_ value: Int8)   throws { try containers.append(unsupportedIntTypeBox(Int8.self, value: Int(value))) }
    func encode(_ value: Int16)  throws { try containers.append(unsupportedIntTypeBox(Int16.self, value: Int(value))) }
    func encode(_ value: Int32)  throws { try containers.append(unsupportedIntTypeBox(Int32.self, value: Int(value))) }
    func encode(_ value: Int64)  throws { try containers.append(unsupportedIntTypeBox(Int64.self, value: Int(value))) }
    func encode(_ value: UInt)   throws { try containers.append(unsupportedIntTypeBox(UInt.self, value: Int(value))) }
    func encode(_ value: UInt8)  throws { try containers.append(unsupportedIntTypeBox(UInt8.self, value: Int(value))) }
    func encode(_ value: UInt16) throws { try containers.append(unsupportedIntTypeBox(UInt16.self, value: Int(value))) }
    func encode(_ value: UInt32) throws { try containers.append(unsupportedIntTypeBox(UInt32.self, value: Int(value))) }
    func encode(_ value: UInt64) throws { try containers.append(unsupportedIntTypeBox(UInt64.self, value: Int(value))) }
    func encode(_ value: Float)  throws { try containers.append(unsupportedDecimalTypeBox(Float.self, value: Double(value))) }

    func encode<T>(_ value: T) throws where T : Encodable {
        switch value {
        case let data as Data:
            try containers.append(box(data))
        case let date as Date:
            try containers.append(box(date))
        default:
            try value.encode(to: self)
        }
    }

    // MARK: Box API

    fileprivate func boxNil() throws -> SingleValueContainer {
        let nilIdentifier = FastRPCObejectType.nil.identifier

        return SingleValueContainer(data: nilIdentifier.usedBytes)
    }

    fileprivate func box(_ value: Bool) throws -> SingleValueContainer {
        let identifier = FastRPCObejectType.bool.identifier

        // Increase identifier if current value is `true`
        var data = value
            ? identifier + 1
            : identifier

        // Serialize identifier
        return SingleValueContainer(data: Data(bytes: &data, count: 1))
    }

    fileprivate func box(_ value: String) throws -> SingleValueContainer {
        // Try ot convert UTF8 string into data
        guard let stringData = value.data(using: .utf8) else {
            // Throw error on failure
            throw FastRPCError.requestEncoding(self, nil)
        }

        // Encode data size into bytes
        let dataBytesSize = stringData.count.usedBytes
        // Create identifier (id + encoded data size)
        let identifier = FastRPCObejectType.string.identifier + (dataBytesSize.count - 1)
        // Create data container for final encoded value
        var data = identifier.usedBytes

        // Combine identifier, content length and content
        data.append(dataBytesSize)
        data.append(stringData)

        // Return converted data
        return SingleValueContainer(data: data)
    }

    fileprivate func box(_ value: Double) throws -> SingleValueContainer {
        // Create identifier exactly 1B in length
        var data = FastRPCObejectType.double.identifier.usedBytes
        // Serialize double using IEEE 754 standard (exactly 8B)
        var bitRepresentation = value.bitPattern
        data.append(Data(bytes: &bitRepresentation, count: bitRepresentation.bitWidth / 8))

        // Combbine identifier with number data
        return SingleValueContainer(data: data)
    }

    fileprivate func box(_ value: Int) throws -> SingleValueContainer {
        // Determine the type of current value
        let type: FastRPCObejectType = value < 0
            ? .int8n
            : .int8p
        // Create copy of `self` and ignore it's sign
        var copy = abs(value)
        // Create identifier using type ID increased by NLEN
        var identifier = type.identifier + (copy.nonTrailingBytesCount - 1)

        // Create data from identifier (alway 1B lenght)
        var identifierData = Data(bytes: &identifier, count: 1)
        let intData = Data(bytes: &copy, count: copy.nonTrailingBytesCount)

        // Concat data (type + value)
        identifierData.append(intData)

        // Stored encoded value
        return SingleValueContainer(data: identifierData)
    }

    fileprivate func box(_ value: Data) throws -> SingleValueContainer {
        // Create data buffer
        var data = Data()
        // Create identifier based on binary length
        let identifier = FastRPCObejectType.binary.identifier + min(0, value.count.nonTrailingBytesCount - 1)

        // Serialize identifier and raw data
        data.append(identifier.usedBytes)
        data.append(value.count.usedBytes)
        data.append(value)

        return SingleValueContainer(data: data)
    }

    fileprivate func box(_ value: Date) throws -> SingleValueContainer {
        let calendar = Calendar.current
        let identifier = FastRPCObejectType.dateTime.identifier
        let dateComponents = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: value)
        // Timezone is represented using hour quarters -> so we convert seconds
        // to minutes (by dividing by 60) and then to hour quartes (by dividing by 15)
        // which for short is dividing by 900
        let timezoneDifference = TimeZone.current.secondsFromGMT() / 900
        // Since timezone difference is always positive, we have to explicitly check
        // whether the timezone is before/after GMT. Advance negative values by 256.
        let timezone = value.isTimezoneAfterGMT()
            // Advance negative values by 256
            ? 256 - timezoneDifference
                // Keep positive values as is
            : timezoneDifference
        let timestamp = Int(value.timeIntervalSince1970)

        // Get components
        let year = max(0, min(dateComponents.year! - 1600, 2047))
        let month = dateComponents.month!
        let day = dateComponents.day!
        // Week starts at sunday and it's ordinal number is '1', we want the sunday to be '0'
        let weekday = dateComponents.weekday! - 1
        let hour = dateComponents.hour!
        let minute = dateComponents.minute!
        let second = dateComponents.second!

        // Define data structure
        let bytes = [
            identifier.truncatedBytes(to: 1),
            timezone.truncatedBytes(to: 1),
            timestamp.truncatedBytes(to: 4),
            ((second & 31) << 3 | weekday & 7).truncatedBytes(to: 1),
            ((minute & 63) << 1 | (second & 32) >> 5 | (hour & 1) << 7).truncatedBytes(to: 1),
            ((hour & 30) >> 1 | (day & 15) << 4).truncatedBytes(to: 1),
            ((day & 31) >> 4 | (month & 15) << 1 | (year & 7) << 5).truncatedBytes(to: 1),
            ((year & 2040) >> 3).truncatedBytes(to: 1)
        ]

        // Combine the data into single result
        let data = bytes.reduce(Data(), +)

        return SingleValueContainer(data: data)
    }

    fileprivate func unsupportedIntTypeBox<T>(_ type: T.Type, value: Int) throws -> SingleValueContainer {
        fallbackImplementationNotice(from: Int.self, to: type)

        return try box(value)
    }

    fileprivate func unsupportedDecimalTypeBox<T>(_ type: T.Type, value: Double) throws -> SingleValueContainer {
        fallbackImplementationNotice(from: type, to: Double.self)

        return try box(value)
    }

    // MARK: - UnkeyedEncodingContainer

    private class FastRPCUnkeyedEncodingContainer: UnkeyedEncodingContainer {
        // MARK: Properties
        var codingPath: [CodingKey]

        var count: Int

        private let encoder: _FastRPCEncoder
        private let container: CollectionContainer

        // MARK: Initializers

        init(codingPath: [CodingKey], encoder: _FastRPCEncoder, container: CollectionContainer) {
            self.codingPath = codingPath
            self.encoder = encoder
            self.container = container
            self.count = 0
        }

        // MARK: Encoding

        func encodeNil()             throws { try container.add(member: encoder.boxNil()) }
        func encode(_ value: Bool)   throws { try container.add(member: encoder.box(value)) }
        func encode(_ value: String) throws { try container.add(member: encoder.box(value)) }
        func encode(_ value: Double) throws { try container.add(member: encoder.box(value)) }
        func encode(_ value: Float)  throws { try container.add(member: encoder.unsupportedDecimalTypeBox(Float.self, value: Double(value))) }
        func encode(_ value: Int)    throws { try container.add(member: encoder.box(value)) }
        func encode(_ value: Int8)   throws { try container.add(member: encoder.unsupportedIntTypeBox(Int8.self, value: Int(value))) }
        func encode(_ value: Int16)  throws { try container.add(member: encoder.unsupportedIntTypeBox(Int16.self, value: Int(value))) }
        func encode(_ value: Int32)  throws { try container.add(member: encoder.unsupportedIntTypeBox(Int32.self, value: Int(value))) }
        func encode(_ value: Int64)  throws { try container.add(member: encoder.unsupportedIntTypeBox(Int64.self, value: Int(value))) }
        func encode(_ value: UInt)   throws { try container.add(member: encoder.unsupportedIntTypeBox(UInt.self, value: Int(value))) }
        func encode(_ value: UInt8)  throws { try container.add(member: encoder.unsupportedIntTypeBox(UInt8.self, value: Int(value))) }
        func encode(_ value: UInt16) throws { try container.add(member: encoder.unsupportedIntTypeBox(UInt16.self, value: Int(value))) }
        func encode(_ value: UInt32) throws { try container.add(member: encoder.unsupportedIntTypeBox(UInt32.self, value: Int(value))) }
        func encode(_ value: UInt64) throws { try container.add(member: encoder.unsupportedIntTypeBox(UInt64.self, value: Int(value))) }

        func encode<T>(_ value: T) throws where T : Encodable {
            fatalError()
        }

        // MARK: Container

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            let container = StructuredContainer()

            return KeyedEncodingContainer(FastRPCKeyedEncodingContainer<NestedKey>(encoder: encoder, container: container))
        }

        func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            let container = CollectionContainer()

            self.container.add(member: container)

            return FastRPCUnkeyedEncodingContainer(codingPath: codingPath, encoder: encoder, container: container)
        }

        func superEncoder() -> Encoder {
            return encoder
        }
    }

    // MARK: - KeyedEncodingContainer

    private class FastRPCKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
        // MARK: Properties

        var codingPath: [CodingKey] = []

        private let encoder: _FastRPCEncoder
        private let container: StructuredContainer

        // MARK: Initializers

        init(encoder: _FastRPCEncoder, container: StructuredContainer) {
            self.container = container
            self.encoder = encoder
        }

        // MARK: Encoding

        func encodeNil(forKey key: Key)               throws { try add(member: encoder.boxNil(), for: key) }
        func encode(_ value: Bool, forKey key: Key)   throws { try add(member: encoder.box(value), for: key) }
        func encode(_ value: String, forKey key: Key) throws { try add(member: encoder.box(value), for: key) }
        func encode(_ value: Double, forKey key: Key) throws { try add(member: encoder.box(value), for: key) }
        func encode(_ value: Float, forKey key: Key)  throws { try add(member: encoder.unsupportedDecimalTypeBox(Float.self, value: Double(value)), for: key) }
        func encode(_ value: Int, forKey key: Key)    throws { try add(member: encoder.box(value), for: key) }
        func encode(_ value: Int8, forKey key: Key)   throws { try add(member: encoder.unsupportedIntTypeBox(Int8.self, value: Int(value)), for: key) }
        func encode(_ value: Int16, forKey key: Key)  throws { try add(member: encoder.unsupportedIntTypeBox(Int16.self, value: Int(value)), for: key) }
        func encode(_ value: Int32, forKey key: Key)  throws { try add(member: encoder.unsupportedIntTypeBox(Int32.self, value: Int(value)), for: key) }
        func encode(_ value: Int64, forKey key: Key)  throws { try add(member: encoder.unsupportedIntTypeBox(Int64.self, value: Int(value)), for: key) }
        func encode(_ value: UInt, forKey key: Key)   throws { try add(member: encoder.unsupportedIntTypeBox(UInt.self, value: Int(value)), for: key) }
        func encode(_ value: UInt8, forKey key: Key)  throws { try add(member: encoder.unsupportedIntTypeBox(UInt8.self, value: Int(value)), for: key) }
        func encode(_ value: UInt16, forKey key: Key) throws { try add(member: encoder.unsupportedIntTypeBox(UInt16.self, value: Int(value)), for: key) }
        func encode(_ value: UInt32, forKey key: Key) throws { try add(member: encoder.unsupportedIntTypeBox(UInt32.self, value: Int(value)), for: key) }
        func encode(_ value: UInt64, forKey key: Key) throws { try add(member: encoder.unsupportedIntTypeBox(UInt64.self, value: Int(value)), for: key) }

        func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
            fatalError()
        }

        // MARK: Container

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            let container = StructuredContainer()

            return KeyedEncodingContainer(FastRPCKeyedEncodingContainer<NestedKey>(encoder: encoder, container: container))
        }

        func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            let container = CollectionContainer()

            codingPath.append(key)

            return FastRPCUnkeyedEncodingContainer(codingPath: codingPath, encoder: encoder, container: container)
        }

        func superEncoder() -> Encoder {
            return encoder
        }

        func superEncoder(forKey key: Key) -> Encoder {
            codingPath.append(key)

            return encoder
        }

        // MARK: Private API

        private func add(member: Container, for key: Key) throws {
            // Convert key to UTF8
            guard let keyData = key.stringValue.data(using: .utf8) else {
                throw EncodingError.invalidValue(key.stringValue, EncodingError.Context(codingPath: codingPath, debugDescription: "Given key is not serializable using UTF8 encoding."))
            }

            // Encode key length and data
            var data = keyData.count.usedBytes
            data.append(keyData)

            // Store member key and value
            container.add(data: data)
            container.add(member: member)
        }
    }

    // MARK: Private API

    private func fallbackImplementationNotice<From, To>(from: From.Type, to: To.Type) {
        debugPrint("[FastFRPCSwift] Required type \(from) is not supported by FastRPC standard. The value will be encoded as \(to) which may cause undefined behavior.")
    }
}
