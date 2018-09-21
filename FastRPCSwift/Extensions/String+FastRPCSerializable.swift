//
//  String+FastRPCSerializable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

extension String: FastRPCSerializable {
    public func serialize() throws -> SerializationBuffer {
        // Try ot convert UTF8 string into data
        guard let data = data(using: .utf8) else {
            // Throw error on failure
            throw FastRPCError.serialization(self, nil)
        }

        // Create identifier for string value (encode id + content length in bytes)
        var dataLength = data.count
        let serializedDataLength = Data(bytes: &dataLength, count: dataLength.nonTrailingBytesCount)

        // Create identifier
        var identifier = FastRPCObejectType.string.identifier + (serializedDataLength.count - 1)
        var serializedIdentifier = Data(bytes: &identifier, count: identifier.nonTrailingBytesCount)

        // Combine identifier, content length and content
        serializedIdentifier.append(serializedDataLength)
        serializedIdentifier.append(data)

        // Return converted data
        return SerializationBuffer(data: serializedIdentifier)
    }
}
