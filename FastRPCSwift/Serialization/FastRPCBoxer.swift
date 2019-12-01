//
//  FastRPCBoxer.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 09/01/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import Foundation

class FastRPCBoxer {
    // MARK: Properties

    private let version: FastRPCProtocolVersion

    // MARK: Initializers

    init(version: FastRPCProtocolVersion = .version2) {
        self.version = version
    }

    // MARK: Public API

    func box(procedure: String, arguments: [Any]) throws -> Data {
        let identifier = FastRPCObejectType.procedure.identifier.bigEndianData

        // Encode procedure data using utf8
        guard let nameData = procedure.data(using: .utf8) else {
            throw FastRPCSerializationError.corruptedStringFormat(procedure)
        }

        // Get bytes representation of encoded name length
        let nameSize = nameData.count.bigEndianData
        // Encode arguments one-by-one as linear data
        let encodedArguments = try arguments
            // Encode each argument separately
            .map { argument in
                try box(argument)
            }
            // Combine array of arguments into flat data structure
            .reduce(Data(), +)

        // Combine all procedure calls informations
        return boxNonDataTypeMeta() + identifier + nameSize + nameData + encodedArguments
    }

    func box(response: Any) throws -> Data {
        // Encode static identifier
        let identifier = FastRPCObejectType.response.identifier.bigEndianData
        // Encode arbitrary (encodable) value
        let valueData = try box(response)

        // Combine identifier and its data
        return boxNonDataTypeMeta() + identifier + valueData
    }

    func box(faultCode code: Int, message: String) throws -> Data {
        let identifier = FastRPCObejectType.fault.identifier.bigEndianData
        let codeData = try box(code)
        let nameData = try box(message)

        return boxNonDataTypeMeta() + identifier + codeData + nameData
    }

    // MARK: Private API

    // MARK: Top level non-data type

    private func boxNonDataTypeMeta() -> Data {
        // Encode non-data type identifiex (0xCALL)
        let identifier = FastRPCObejectType.nonDataType.identifier.bigEndianData
        // Encode FRPC version
        let major = version.major.bigEndianData
        let minor = version.minor.bigEndianData

        return identifier + major + minor
    }

    // MARK: Box type evaluation

    private func box(_ value: Any) throws -> Data {
        switch value {
        case let null as NSNull:
            return try box(null)
        case let bool as Bool:
            return try box(bool)
        case let string as String:
            return try box(string)
        case let int as Int:
            return try box(int)
        case let double as Double:
            return try box(double)
        case let data as Data:
            return try box(data)
        case let date as Date:
            return try box(date)
        case let array as NSArray:
            return try box(array)
        case let structure as NSDictionary:
            return try box(structure)
        default:
            throw FastRPCSerializationError.unsupportedObject(value)
        }
    }

    // MARK: Box specific types

    private func box(_ value: NSNull) throws -> Data {
        let nilIdentifier = FastRPCObejectType.nil.identifier

        return nilIdentifier.bigEndianData
    }

    private func box(_ value: Bool) throws -> Data {
        let identifier = FastRPCObejectType.bool.identifier

        // Increase identifier if current value is `true`
        let data = value
            ? identifier + 1
            : identifier

        return data.bigEndianData
    }

    private func box(_ value: String) throws -> Data {
        // Try ot convert UTF8 string into data
        guard let stringData = value.data(using: .utf8) else {
            // Throw error on failure
            throw FastRPCSerializationError.corruptedStringFormat(value)
        }

        // For FRPC 1.0, we don't use nlen so we don't have to substract 1,
        // for version above we have to substract 1 (nlen format)
        let countModifier = version == .version1
            ? 0
            : -1
        // Encode data size into bytes
        let dataBytesSize = stringData.count.bigEndianData
        // Sanitize modified count so it's not off bounds
        let sanitizedCount = max(0, dataBytesSize.count + countModifier)
        // Create identifier (id + encoded data size)
        let identifier = FastRPCObejectType.string.identifier + sanitizedCount

        // Return converted data
        return identifier.bigEndianData + dataBytesSize + stringData
    }

    private func box(_ value: Double) throws -> Data {
        // Create identifier exactly 1B in length
        let identifierData = FastRPCObejectType.double.identifier.bigEndianData
        // Serialize double using IEEE 754 standard (exactly 8B)
        var bitRepresentation = value.bitPattern
        let valueData = Data(bytes: &bitRepresentation, count: bitRepresentation.bitWidth / 8)

        // Combine identifier with number data
        return identifierData + valueData
    }

    private func box(_ value: Int) throws -> Data {
        // Select encoding based on current FRPC protocol version
        switch version {
        case .version1:
            return try boxUnifiedInt(value)
        case .version2, .version2_1:
            return try boxInteger8PosNeg(value)
        case .version3:
            return try boxZigZagInt(value)
        }
    }

    private func boxUnifiedInt(_ value: Int) throws -> Data {
        #warning("This may not be correct encoding")
        // Encode value using raw bytes copy
        let bytes = value.littleEndianData
        // Add bytes count as additional type info (!does not use nlen!)
        let identifier = FastRPCObejectType.int.identifier + bytes.count

        return identifier.bigEndianData + bytes
    }

    private func boxInteger8PosNeg(_ value: Int) throws -> Data {
        // Determine the type of current value
        let type: FastRPCObejectType = value < 0
            ? .int8n
            : .int8p
        // Create copy of `self` and ignore it's sign
        let unsigned = abs(value)
        // Create identifier using type ID increased by NLEN
        let identifierData = (type.identifier + nlen(forCount: unsigned)).bigEndianData
        // Encode value itself
        let intData = unsigned.littleEndianData

        // Combine identifier with encoded value
        return identifierData + intData
    }

    private func boxZigZagInt(_ value: Int) throws -> Data {
        // Encode int using zig-zag encoding
        let int = (value >> MemoryLayout<Int>.size - 1) ^ (value << 1)
        // Add data nlen to identifier
        let identifier = FastRPCObejectType.int.identifier + nlen(forCount: int)

        return identifier.bigEndianData + int.littleEndianData
    }

    private func box(_ value: Data) throws -> Data {
        // Create identifier based on binary length
        let identifier = FastRPCObejectType.binary.identifier + nlen(forCount: value.count)

        // Combine meta info with value
        return identifier.bigEndianData + value.count.bigEndianData + value
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
        let bytes: [Data] = [
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

    private func box(_ value: NSArray) throws -> Data {
        let identifier = FastRPCObejectType.array.identifier
        // Get raw representation of array length
        let nlen = self.nlen(forCount: value.count)
        // Encode the identifier
        let identifierData = (identifier + nlen).bigEndianData
        // Box all elements from collection
        let elementsData = try value
            // Box the elements
            .map { element in
                try box(element)
            }
            // Flatten the array of raw data
            .reduce(Data(), +)

        // Compose the final value using identifier, count and elements data
        return identifierData + value.count.bigEndianData + elementsData
    }

    private func box(_ value: NSDictionary) throws -> Data {
        let identifier = FastRPCObejectType.struct.identifier
        // Get raw representation of number of fields
        let nlen = self.nlen(forCount: value.count)
        // Encode the identifier
        let identifierData = (identifier + nlen).bigEndianData
        // Box all struct fields
        let fields = try value
            .map { key, value -> Data in
                guard let stringKey = key as? String else {
                    throw FastRPCSerializationError.unsupportedFieldNameObject(key)
                }

                // Encode the field name
                let keyData = stringKey.data(using: .utf8)!
                // Encode arbitrary field value
                let valueData = try box(value)

                // Combine key-value pair data
                return keyData.count.bigEndianData + keyData + valueData
            }
            // Flatten fields into linear data representation
            .reduce(Data(), +)

        // Combine the structure meta with fields data
        return identifierData + value.count.bigEndianData + fields
    }

    private func nlen(forCount count: Int) -> Int {
        return max(0, count.littleEndianData.count - 1)
    }
}
