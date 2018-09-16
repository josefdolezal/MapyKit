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

        // See the `encode(_:)` docs
        let valueData = encode(abs(self))
        // Create serialized value identifier
        let identifier = type.identifier + Swift.max(0, valueData.count - 1)
        // Int values representing key-value pair
        let data = [identifier] + valueData

        return Data(data)
    }

    /// Encodes given value into data using FastRPC standard. Encoded value must be greater than or equal to zero.
    /// Implementation is taken from `JAK.FRPC._encodeInt` which may be found on https://api.mapy.cz/js/api/v5/smap-jak.js?v=4.13.27 .
    ///
    /// - Returns: Self encoded into data
    private func encode(_ value: Int) -> [Int] {
        // Create buffer for integer serialization
        var buffer = [Int]()
        // Create mutable copy of given value
        var encodedValue = value

        // Be sure that zero is explicitly encoded (would go through following loop otherwise)
        if encodedValue == 0 {
            return [0]
        }

        // Convert the value into data using FastRPC standard
        while encodedValue != 0 {
            let partial = encodedValue % 256

            encodedValue = (encodedValue - partial) / 256
            buffer.append(encodedValue)
        }

        return buffer
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
