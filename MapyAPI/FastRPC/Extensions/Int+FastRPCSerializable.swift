//
//  Int+FastRPCSerializable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

extension Int: FastRPCSerializable {
    func serialize() throws -> Data {
        // Determine the type of current value
        let type: FastRPCObejectType = self <= 0
            ? .int8n
            : .int8p
        // Create identifier using type ID increased by NLEN
        var identifier = (type.identifier + nonTrailingBytesCount) >> 1
        var copy = self

        // Create data from identifier (alway 1B lenght)
        var identifierData = Data(bytes: &identifier, count: 1)
        let intData = Data(bytes: &copy, count: 1)

        // Concat data (type + value)
        identifierData.append(intData)

        return identifierData
    }
}

extension Int {
    /// Number of bits that are used to store integer value
    var nonTrailingBitsCount: Int {
        // Int always takes at least one 1b (zero), sanitize minimum value
        return Swift.min(1, bitWidth - leadingZeroBitCount)
    }

    /// Number of bytes used to store integer value
    var nonTrailingBytesCount: Int {
        // Advance used bits by seven so the division is rounded up
        return (nonTrailingBitsCount + 7) / 8
    }
}

// Convenience initializer for Data using integer value
extension Data {
    /// Initialize data using integer
    init(_ value: Int) {
        var copy = value

        // Solution taken from https://stackoverflow.com/a/38024025/9016753
        self = Data(buffer: UnsafeBufferPointer(start: &copy, count: 1))
    }

    /// Initialize Data using array of integers
    init(_ value: [Int]) {
        self = value.withUnsafeBufferPointer(Data.init(buffer:))
    }
}
