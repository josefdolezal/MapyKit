//
//  Int+FastRPCSerializable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

extension Int: FastRPCSerializable {
    public func serialize() throws -> SerializationBuffer {
        // Determine the type of current value
        let type: FastRPCObejectType = self < 0
            ? .int8n
            : .int8p
        // Create copy of `self` and ignore it's sign
        var copy = abs(self)
        // Create identifier using type ID increased by NLEN
        var identifier = type.identifier + (copy.nonTrailingBytesCount - 1)

        // Create data from identifier (alway 1B lenght)
        var identifierData = Data(bytes: &identifier, count: 1)
        let intData = Data(bytes: &copy, count: copy.nonTrailingBytesCount)

        // Concat data (type + value)
        identifierData.append(intData)

        return SerializationBuffer(data: identifierData)
    }
}

extension Int {
    /// Number of bits that are used to store integer value
    var nonTrailingBitsCount: Int {
        // Int always takes at least one 1b (zero), sanitize minimum value
        return Swift.max(1, bitWidth - leadingZeroBitCount)
    }

    /// Number of bytes used to store integer value
    var nonTrailingBytesCount: Int {
        // Advance used bits by seven so the division is rounded up
        return (nonTrailingBitsCount + 7) / 8
    }
}
