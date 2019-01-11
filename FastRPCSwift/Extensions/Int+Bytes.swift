//
//  Int+Bytes.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

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

    var littleEndianData: Data {
        var copy = self

        return Data(bytes: &copy, count: copy.nonTrailingBytesCount)
    }

    var bigEndianData: Data {
        return Data(littleEndianData.reversed())
    }

    func truncatedBytes(to length: Int) -> Data {
        let sanitizedLength = Swift.min(length, bitWidth / 8)
        var copy = self

        return Data(bytes: &copy, count: sanitizedLength)
    }

    /// Initializes Integer from raw data. Data must be little endian representation of integer and
    /// must not contain more bytes that is used to represent integer.
    init(data: Data) {
        // Check if byte representation is convertible from given data
        assert(MemoryLayout<Int>.size >= data.count)

        // Convert data to Integer - discussion: we cannot use standard solution using memory layout,
        // since it work only with properly aligned bytes (count matches with actual implementation)
        // therefore we use bits shifting with sum
        self = data
            // Get each bytes offset
            .enumerated()
            // Shift bytes by it's offset
            .map { offset, byte in
                return Int(byte) << (offset * 8)
            }
            // Sum the bytes to get the actual value
            .reduce(0, +)
    }
}
