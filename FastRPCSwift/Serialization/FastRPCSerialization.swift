//
//  FastRPCSerialization.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

public enum FastRPCDecodingError: Error {
    case missingTypeIdentifier
    case unknownTypeIdentifier
    case corruptedData
    case unexpectedTopLevelObject
    case unsupportedNonDataType
    case unsupportedProtocolVersion(major: Int, minor: Int)
    case keyNotFound(CodingKey)
    case typeMismatch(expected: Any, actual: Any)
    case unsupportedType(Any, replacement: Any)
    case containerIsAtEnd
}

public class FastRPCSerialization {

    private init () { }

    static func object(with data: Data) throws -> Any {
        let unboxer = FastRPCUnboxer(data: data)

        let any = try unboxer.unbox()

        dump(any)

        return any
    }

    static func data(withObject object: Any) throws -> Data {
        fatalError()
    }
}

private class FastRPCBoxer {
    // MARK: Properties

    private var container: Any

    // MARK: Initializers

    init(container: Any) {
        self.container = container
    }

    // MARK: Public API

    public func box() throws -> Data {
        switch container {
        case let null as NSNull:
            return try box(null)
        case let bool as Bool:
            return try box(bool)
        case let string as String:
            return try box(string)
        case let double as Double:
            return try box(double)
        case let int as Int:
            return try box(int)
        case let data as Data:
            return try box(data)
        case let date as Date:
            return try box(date)
        default:
            fatalError()
        }
    }

    // MARK: Private API

    private func box(_ value: NSNull) throws -> Data {
        let nilIdentifier = FastRPCObejectType.nil.identifier

        return nilIdentifier.usedBytes
    }

    private func box(_ value: Bool) throws -> Data {
        let identifier = FastRPCObejectType.bool.identifier

        // Increase identifier if current value is `true`
        let data = value
            ? identifier + 1
            : identifier

        return data.usedBytes
    }

    private func box(_ value: String) throws -> Data {
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
        return data
    }

    private func box(_ value: Double) throws -> Data {
        // Create identifier exactly 1B in length
        var data = FastRPCObejectType.double.identifier.usedBytes
        // Serialize double using IEEE 754 standard (exactly 8B)
        var bitRepresentation = value.bitPattern
        data.append(Data(bytes: &bitRepresentation, count: bitRepresentation.bitWidth / 8))

        // Combbine identifier with number data
        return data
    }

    private func box(_ value: Int) throws -> Data {
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
        return identifierData
    }

    private func box(_ value: Data) throws -> Data {
        // Create data buffer
        var data = Data()
        // Create identifier based on binary length
        let identifier = FastRPCObejectType.binary.identifier + min(0, value.count.nonTrailingBytesCount - 1)

        // Serialize identifier and raw data
        data.append(identifier.usedBytes)
        data.append(value.count.usedBytes)
        data.append(value)

        return data
    }

    private func box(_ value: Date) throws -> Data {
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

        return data
    }

    private func box(_ type: Procedure0) throws -> Data {
        fatalError()
    }
}

private class FastRPCUnboxer {
    private var data: Data

    init(data: Data) {
        self.data = data
    }

    public func unbox() throws -> Any {
        let type = try validateType()

        switch type {
        case .nil: return try unboxNil()
        case .bool: return try unbox(Bool.self)
        case .double: return try unbox(Double.self)
        case .int, .int8p, .int8n: return try unbox(Int.self)
        case .string: return try unbox(String.self)
        case .dateTime: return try unbox(Date.self)
        case .binary: return try unbox(Data.self)

        case .nonDataType: return try unboxNonDataType()

        case .array: return try unbox(NSArray.self)
        case .struct: return try unbox(NSDictionary.self)

        // These must be wrapped inside non-data type
        case .procedure: throw FastRPCDecodingError.unexpectedTopLevelObject
        case .response: throw FastRPCDecodingError.unexpectedTopLevelObject
        case .fault: throw FastRPCDecodingError.unexpectedTopLevelObject
        }
    }

    // MARK: Unboxing API

    private func unbox(_ type: Bool.Type) throws -> Bool {
        // Get bool byte
        let bool = data.removeFirst()

        // Check bool by equality on LSB
        return bool & 1 == 1
    }

    private func unbox(_ type: Double.Type) throws -> Double {
        // Remove type information
        data.removeFirst()

        // Get double data (fixed size for IEEE 754)
        let bytes = try expectBytes(count: 8)

        // Convert raw data into double
        return bytes.withUnsafeBytes { $0.pointee }
    }

    private func unbox(_ type: Int.Type) throws -> Int {
        // Check first for type information (without last 3 additional info bits)
        guard let type = data.first.map({ Int($0 & 0xF8) }) else {
            throw FastRPCDecodingError.corruptedData
        }

        // Switch over int identifier
        switch type {
        case FastRPCObejectType.int8p.identifier: return try unboxPositiveInteger()
        case FastRPCObejectType.int8n.identifier: return try unboxNegativeInteger()
        case FastRPCObejectType.int.identifier: return try unboxZigZagInteger()
        default:
            throw FastRPCDecodingError.unknownTypeIdentifier
        }
    }

    private func unbox(_ type: String.Type) throws -> String {
        // Get size of string data
        let info = try expectTypeAdditionalInfo()
        // Get string data length from additional data,
        // increase required count by one (FRPC standard)
        let lengthDataSize = Int(info) + 1
        // Get data containing info about string data length
        let stringLengthData = try expectBytes(count: lengthDataSize)
        // Get string length
        let stringDataSize = Int(data: stringLengthData)
        /// Get actual encoded string data
        let stringData = try expectBytes(count: stringDataSize)

        // Decode string data with utf8 encoding
        guard let string = String(data: stringData, encoding: .utf8) else {
            throw FastRPCDecodingError.corruptedData
        }

        return string
    }

    private func unbox(_ type: NSArray.Type) throws -> NSArray {
        // Get count of bytes keeping the array size
        let info = try expectTypeAdditionalInfo()
        // Get the number of elements (convert next `info + 1` bytes to Int)
        let size = try Int(data: expectBytes(count: Int(info + 1)))
        // Create the elements container
        let array = NSMutableArray()

        // Extract exactly `size` elements
        for _ in 0 ..< size {
            try array.add(unbox())
        }

        return array
    }

    private func unbox(_ type: NSDictionary.Type) throws -> NSDictionary {
        // Get count of bytes keeping the number of members
        let info = try expectTypeAdditionalInfo()
        // Get number of members (convert next `info + 1` bytes to Int)
        let size = try Int(data: expectBytes(count: Int(info) + 1))
        /// Create the members container
        let structure = NSMutableDictionary()

        // Extract exactly `size` members
        for _ in 0 ..< size {
            // Get size of bytes keeping member name
            let nameSize = try Int(data: expectBytes(count: 1))
            // Get member name data
            let nameData = try expectBytes(count: nameSize)
            // Unbox member name UTF8 encoded string, fail decoding on error
            guard let name = String(data: nameData, encoding: .utf8) else {
                throw FastRPCDecodingError.corruptedData
            }
            // Unbox arbitrary value
            let value = try unbox()

            // Save key-value pair into structure
            structure.setValue(value, forKey: name)
        }

        return structure
    }

    private func unboxPositiveInteger() throws -> Int {
        let info = try expectTypeAdditionalInfo()
        // Encode int size and increase it by 1 (FRPC standard)
        let dataSize = Int(info) + 1
        // Get expected bytes
        let bytes = try expectBytes(count: dataSize)

        // Return converted bytes
        return Int(data: bytes)
    }

    private func unboxNegativeInteger() throws -> Int {
        let info = try expectTypeAdditionalInfo()
        // Encode int size and increase it by 1 (FRPC standard)
        let dataSize = Int(info) + 1
        // Get expected bytes
        let bytes = try expectBytes(count: dataSize)
        // Convert data to integer
        let int = Int(data: bytes)

        return -int
    }

    private func unboxZigZagInteger() throws -> Int {
        fatalError()
    }

    private func unboxNil() throws -> NSObject {
        // Remove the nil byte
        data.removeFirst()

        // Represent nil using objc
        return NSNull()
    }

    private func unbox(_ type: Data.Type) throws -> Data {
        // Get bytes size of data count
        let info = try expectTypeAdditionalInfo()
        // Get info + 1 bytes which represents raw data count
        let size = try Int(data: expectBytes(count: Int(info + 1)))
        // Get the raw data
        let data = try expectBytes(count: size)

        return data
    }

    private func unbox(_ type: Date.Type) throws -> Date {
        // We don't need any additional info, just remove the info byte from queue
        _ = try expectTypeAdditionalInfo()
        // Remove the timezone info
        _ = try Int(data: expectBytes(count: 1))
        // Get the unix timestamps
        let timestamp = Int(data: try expectBytes(count: 4))
        let timeInterval = TimeInterval(timestamp)
        // Remove additional data informations (year, day of week, ...)
        _ = try expectBytes(count: 5)

        // We can ignore timezone and additional date data since
        // we use unix timestamp which is standardized in UTC timezone
        return Date(timeIntervalSince1970: timeInterval)
    }

    // MARK: Non-data types

    private func unboxNonDataType() throws -> Any {
        // Ignore the non-data type multi-byte identifier
        _ = try expectBytes(count: 2)
        // Get FRPC version
        let major = try Int(data: expectBytes(count: 1))
        let minor = try Int(data: expectBytes(count: 1))

        // Get FRPC protocol version
        guard
            major == FastRPCProtocolVersion.major,
            minor == FastRPCProtocolVersion.minor
        else {
            throw FastRPCDecodingError.unsupportedProtocolVersion(major: major, minor: minor)
        }

        // Check for the inner type
        let type = try validateType()

        // We only support subset of types as inner object
        switch type {
        case .response: return try unboxResponse()
        case .procedure: return try unboxProcedure()
        case .fault: return try unbox(Fault.self)
        default:
            throw FastRPCDecodingError.unsupportedNonDataType
        }
    }

    private func unboxProcedure() throws -> Any {
        // Ignore the additional type info
        _ = try expectTypeAdditionalInfo()
        // Get number of procedure name bytes count
        let size = try Int(data: expectBytes(count: 1))
        // Get the procedure data and convert it to string
        let nameData = try expectBytes(count: size)

        guard let name = String(data: nameData, encoding: .utf8) else {
            throw FastRPCDecodingError.corruptedData
        }

        // Procedures does not match the standard structure of data since it's not
        // neither single value, key-value container or collection container.
        // Therefore we internaly have to create procedure structured and decode it
        // as structured data.
        switch size {
        case 0:
            return Procedure0(name: name)
        case 1:
            return try unboxProcedure1(name: name)
        default:
            throw FastRPCDecodingError.corruptedData
        }
    }

    private func unboxResponse() throws -> Any {
        // Remove the unused type information
        _ = try expectTypeAdditionalInfo()
        // Ignore the Response container, return it's content only
        return try unbox()
    }

    private func unbox(_ type: Fault.Type) throws -> Fault {
        // Throw out fault response signature
        _ = try expectTypeAdditionalInfo()
        // Try to decode fault content
        do {
            let code = try unbox(Int.self)
            let message = try unbox(String.self)

            return Fault(code: code, message: message)
        } catch {
            // Throw custom error if either code or messae decoding fails
            throw FastRPCDecodingError.corruptedData
        }
    }

    // MARK: Procedures unboxing

    private func unboxProcedure1(name: String) throws -> Any {
        return try structurizeProcedure(name: name, args: unbox())
    }

    private func structurizeProcedure(name: String, args: Any...) -> Any {
        // Create fake structure
        let structure = NSDictionary(dictionary: [
            "name": name,
            "arguments": args
        ])

        return structure
    }

    // MARK: Private API

    private func validateType() throws -> FastRPCObejectType {
        // Make the type info mutable so we can replace it with multibyte
        // representation later.
        guard var typeInfo = data.first.map({ Int($0 & 0xF8) }) else {
            throw FastRPCDecodingError.missingTypeIdentifier
        }

        // Extend type to multibyte representation, add last three bytes by adding '2'
        let extendedTypeInfo = ((typeInfo + 2) << 8) + 0x11

        // Explicitly check for non-data type information, which uses two
        // bytes instead of typical one.
        if extendedTypeInfo == FastRPCObejectType.nonDataType.identifier {
            typeInfo = extendedTypeInfo
        }

        // Continue with original `typeInfo` property since multibyte encoding is
        // handled before.
        guard let type = FastRPCObejectType(rawValue: typeInfo) else {
            throw FastRPCDecodingError.unknownTypeIdentifier
        }

        return type
    }

    private func expectBytes(count: Int) throws -> Data {
        // Check if we have required bytes count
        guard data.count >= count else {
            throw FastRPCDecodingError.corruptedData
        }

        // Get expected bytes and remove it
        let bytes = data.prefix(count)
        data.removeFirst(count)

        return bytes
    }

    private func expectTypeAdditionalInfo() throws -> UInt8 {
        guard data.first != nil else {
            throw FastRPCDecodingError.missingTypeIdentifier
        }

        // Return just last three bits
        return data.removeFirst() & 0x07
    }
}
