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

        return try unboxer.unbox()
    }

    static func data(withObject object: Any) throws -> Data {
        let boxer = FastRPCBoxer(container: object)

        return try boxer.box()
    }
}

public struct Procedure1<Arg: Codable>: Codable {
    var name: String
    var arg: Arg

    public init(name: String, arg: Arg) {
        self.name = name
        self.arg = arg
    }

    public init(from decoder: Decoder) throws {
        // Due to limitations of type system, we do not support 3rd party decoders
        guard let decoder = decoder as? _FastRPCDecoder else {
            assertionFailure("FastRPC Procedure is only decodable from internal FastRPCDecoder.")
            #warning("Should not fatal error here")
            fatalError()
        }

        // Decode procedure as temporary variable and initialize `self` using this var.
        // This workaround due to usage of [Any] as arguments list, the initializer cannot
        // be synthetized by compiler.
        var container = try decoder.procedureContainer()

        self.name = try container.decode(String.self)
        self.arg = try container.decode(Arg.self)
    }

    public func encode(to encoder: Encoder) throws {
        // Due to limitations of type system, we do not support 3rd party encoders.
        // This workaround due to usage of [Any] as arguments list, the encoding method cannot
        // be synthetized by compiler.
        assert(encoder is FastRPCEncoder, "FastRPC Procedure is only encodable using internal FastRPCEncoder.")

        var container = encoder.unkeyedContainer()

        try container.encode(self)
    }
}

public struct Procedure2<Arg1: Codable, Arg2: Codable>: Codable {
    var name: String
    var arg1: Arg1
    var arg2: Arg2

    public init(name: String, arg1: Arg1, arg2: Arg2) {
        self.name = name
        self.arg1 = arg1
        self.arg2 = arg2
    }

    public init(drom decoder: Decoder) throws {
        // Due to limitations of type system, we do not support 3rd party decoders
        guard let decoder = decoder as? _FastRPCDecoder else {
            assertionFailure("FastRPC Procedure is only decodable from internal FastRPCDecoder.")
            #warning("Should not fatal error here")
            fatalError()
        }

        var container = try decoder.procedureContainer()

        self.name = try container.decode(String.self)
        self.arg1 = try container.decode(Arg1.self)
        self.arg2 = try container.decode(Arg2.self)
    }

    #warning("Implement procedure encoding")
}

class UntypedProcedure {
    var name: String
    var arguments: [Any]

    init(name: String, arguments: [Any]) {
        self.name = name
        self.arguments = arguments
    }
}

public struct Response<Value: Decodable>: Decodable {
    public var value: Value

    public init(value: Value) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        fatalError()
    }

    public func encode(to encoder: Encoder) throws {
        #warning("Implement response encoding")
        fatalError()
    }
}

class UntypedResponse: Codable {
    var value: Any

    init(value: Any) {
        self.value = value
    }

    required init(from decoder: Decoder) throws {
        assert(decoder is FastRPCDecoder, "FastRPC Response is only decodable from internal FastRPCDecoder.")

        let container = try decoder.singleValueContainer()
        let response = try container.decode(UntypedResponse.self)

        self.value = response.value
    }

    func encode(to encoder: Encoder) throws {
        assert(encoder is FastRPCEncoder, "FastRPC Response is only encodable using internal FastRPCEncoder.")

        var container = encoder.singleValueContainer()

        try container.encode(self)
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

    func box() throws -> Data {
        // FRPC standard allows only certain objects to be at top-level, check for these
        // before boxing potential nested containers.
        switch container {
        case let fault as Fault:
            return try box(fault)
        case let procedure as UntypedProcedure:
            return try box(procedure)
        case let response as UntypedResponse:
            return try box(response)
        default:
            #warning("Throw unsupported type")
            fatalError("Unsupported top-level type")
        }
    }

    // MARK: Private API

    // MARK: Top level non-data types

    private func box(_ value: UntypedProcedure) throws -> Data {
        let identifier = FastRPCObejectType.procedure.identifier.usedBytes

        // Encode procedure data using utf8
        guard let nameData = value.name.data(using: .utf8) else {
            throw FastRPCError.requestEncoding(self, nil)
        }

        // Get bytes representation of encoded name length
        let nameSize = nameData.count.usedBytes
        // Encode arguments one-by-one as linear data
        let arguments = try value.arguments
            // Encode each argument separately
            .map { argument in
                try box(argument)
            }
            // Combine array of arguments into flat data structure
            .reduce(Data(), +)

        // Combine all procedure calls informations
        return identifier + nameSize + nameData + arguments
    }

    private func box(_ value: Fault) throws -> Data {
        let identifier = FastRPCObejectType.fault.identifier.usedBytes

        let codeData = value.code.usedBytes

        guard let nameData = value.message.data(using: .utf8) else {
            throw FastRPCError.requestEncoding(self, nil)
        }

        return identifier + codeData + nameData
    }

    private func box(_ value: UntypedResponse) throws -> Data {
        // Encode static identifier
        let identifier = FastRPCObejectType.response.identifier.usedBytes
        // Encode arbitrary (encodable) value
        let valueData = try box(value.value)

        // Combine identifier and its data
        return identifier + valueData
    }

    // MARK: Box type evaluation

    func box(_ value: Any) throws -> Data {
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
        case let fault as Fault:
            return try box(fault)
        case let procedure as UntypedProcedure:
            return try box(procedure)
        case let response as UntypedResponse:
            return try box(response)
        case let array as NSArray:
            return try box(array)
        case let structure as NSDictionary:
            return try box(structure)
        default:
            #warning("Should throw an error")
            fatalError()
        }
    }

    // MARK: Box specific types

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
        let identifier = FastRPCObejectType.string.identifier + nlen(forCount: dataBytesSize.count)

        // Return converted data
        return identifier.usedBytes + dataBytesSize + stringData
    }

    private func box(_ value: Double) throws -> Data {
        // Create identifier exactly 1B in length
        let identifierData = FastRPCObejectType.double.identifier.usedBytes
        // Serialize double using IEEE 754 standard (exactly 8B)
        var bitRepresentation = value.bitPattern
        let valueData = Data(bytes: &bitRepresentation, count: bitRepresentation.bitWidth / 8)

        // Combine identifier with number data
        return identifierData + valueData
    }

    private func box(_ value: Int) throws -> Data {
        // Determine the type of current value
        let type: FastRPCObejectType = value < 0
            ? .int8n
            : .int8p
        // Create copy of `self` and ignore it's sign
        let unsigned = abs(value)
        // Create identifier using type ID increased by NLEN
        let identifierData = (type.identifier + nlen(forCount: unsigned.nonTrailingBitsCount)).usedBytes
        // Encode value itself
        let intData = unsigned.usedBytes

        #warning("Encode Int based on current frpc version specified by user")

        // Combine identifier with encoded value
        return identifierData + intData
    }

    private func box(_ value: Data) throws -> Data {
        // Create identifier based on binary length
        let identifier = FastRPCObejectType.binary.identifier + nlen(forCount: value.count)

        // Combine meta info with value
        return identifier.usedBytes + value.count.usedBytes + value
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

    private func box(_ value: NSArray) throws -> Data {
        let identifier = FastRPCObejectType.array.identifier
        // Get raw representation of array length
        let nlen = self.nlen(forCount: value.count)
        // Encode the identifier
        let identifierData = (identifier + nlen).usedBytes
        // Box all elements from collection
        let elementsData = try value
            // Box the elements
            .map { element in
                try box(element)
            }
            // Flatten the array of raw data
            .reduce(Data(), +)

        // Compose the final value using identifier, count and elements data
        return identifierData + value.count.usedBytes + elementsData
    }

    private func box(_ value: NSDictionary) throws -> Data {
        let identifier = FastRPCObejectType.struct.identifier
        // Get raw representation of number of fields
        let nlen = self.nlen(forCount: value.count)
        // Encode the identifier
        let identifierData = (identifier + nlen).usedBytes
        // Box all struct fields
        let fields = try value
            .map { key, value -> Data in
                #warning("Should check safely for key type")
                // Encode the field name
                let keyData = (key as! String).data(using: .utf8)!
                // Encode arbitrary field value
                let valueData = try box(value)

                // Combine key-value pair data
                return keyData.count.usedBytes + keyData + valueData
            }
            // Flatten fields into linear data representation
            .reduce(Data(), +)

        // Combine the structure meta with fields data
        return identifierData + value.count.usedBytes + fields
    }

    private func nlen(forCount count: Int) -> Int {
        return max(0, count.usedBytes.count - 1)
    }
}

private class FastRPCUnboxer {
    /// Data representing FRPC encoded object
    private var data: Data
    /// Version of the FRPC protocol used to decode stored object (default: 3.0)
    private var version = FastRPCProtocolVersion.version3

    init(data: Data) {
        self.data = data
    }

    func unbox() throws -> Any {
        // Get the data type
        let type = try validateType()

        // We only support subset of types at top level
        guard type == .nonDataType else {
            throw FastRPCDecodingError.unexpectedTopLevelObject
        }

        // Unbox the non-data type
        return try unboxNonDataType()
    }

    // MARK: Unbox type evaluation

    private func unboxNestedValue() throws -> Any {
        // Get the data type
        let type = try validateType()

        switch type {
        // Primitives
        case .nil: return try unboxNil()
        case .bool: return try unbox(Bool.self)
        case .double: return try unbox(Double.self)
        case .int, .int8p, .int8n: return try unbox(Int.self)
        case .string: return try unbox(String.self)
        case .dateTime: return try unbox(Date.self)
        case .binary: return try unbox(Data.self)

        // Composite data types
        case .array: return try unbox(NSArray.self)
        case .struct: return try unbox(NSDictionary.self)

        // Non-data types wrapper identifier
        case .nonDataType: return try unboxNonDataType()

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
        case FastRPCObejectType.int.identifier:
            switch version {
            case .version1:
                return try unboxUnifiedInteger()
            case .version2:
                // Version 2 does not specify Int identifier (it uses separate Int8+/-),
                // so the identifier is unknown
                throw FastRPCDecodingError.unknownTypeIdentifier
            case .version3:
                return try unboxZigZagInteger()
            }
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
            try array.add(unboxNestedValue())
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
            let value = try unboxNestedValue()

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
        let info = try expectTypeAdditionalInfo()
        // Get number of bytes encoding int
        let dataSize = Int(info) + 1
        // Get bytes representing the int
        let bytes = try expectBytes(count: dataSize)
        // Get the int value
        let int = Int(data: bytes)

        // Decode using zig zag
        return (int >> 1) ^ (-(int & 1))
    }

    /// Unboxes unified signed integer (used by standard FRPC 1.0).
    private func unboxUnifiedInteger() throws -> Int {
        // Get number of bytes used by integer
        let info = try expectTypeAdditionalInfo()
        // Get bytes representing integer
        let bytes = try expectBytes(count: Int(info))

        // Simply convert data into integer
        return Int(data: bytes)
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

        // Identify the procol version from type meta
        guard let version = FastRPCProtocolVersion(rawValue: major) else {
            throw FastRPCDecodingError.unsupportedProtocolVersion(major: major, minor: minor)
        }

        // Override currently used protocol version
        self.version = version

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
        // Get number of bytes used by procedure name
        let size = try Int(data: expectBytes(count: 1))
        // Get the procedure name data and convert it to string
        let nameData = try expectBytes(count: size)
        // Create temporary container for arguments unboxing
        var arguments = [Any]()

        // The name must be encoded using UTF8
        guard let name = String(data: nameData, encoding: .utf8) else {
            throw FastRPCDecodingError.corruptedData
        }

        // We expect the parameters to be lineary aligned
        while !data.isEmpty {
            arguments.append(try unboxNestedValue())
        }

        return UntypedProcedure(name: name, arguments: arguments)
    }

    private func unboxResponse() throws -> Any {
        // Remove the unused type information
        _ = try expectTypeAdditionalInfo()

        // Wrap remote response with internal type
        return UntypedResponse(value: try unboxNestedValue())
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
