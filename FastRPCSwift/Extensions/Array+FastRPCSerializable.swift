//
//  Array+FastRPCSerializable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

extension Array: FastRPCSerializable where Element: FastRPCSerializable {
    public func serialize() throws -> SerializationBuffer {
        // Encode the size into bytes
        var size = count
        let sizeData = Data(bytes: &size, count: size.nonTrailingBytesCount)
        // Advance identifier by number of encoded size components
        var identifier = FastRPCObejectType.array.identifier + sizeData.count - 1
        let identifierData = Data(bytes: &identifier, count: identifier.nonTrailingBytesCount)
        // Buffer for final data
        var data = Data()

        let elementsData = try self
            // Convert each element into data
            .map { try $0.serialize().data }
            // Reduce data bby merging all elements bytes
            .reduce(Data(), +)


        // Build the final data structure
        data.append(identifierData)
        data.append(sizeData)
        data.append(elementsData)

        return SerializationBuffer(data: data)
    }
}
