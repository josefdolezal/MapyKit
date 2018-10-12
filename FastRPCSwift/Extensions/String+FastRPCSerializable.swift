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
        guard let stringData = self.data(using: .utf8) else {
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
        return SerializationBuffer(data: data)
    }
}
