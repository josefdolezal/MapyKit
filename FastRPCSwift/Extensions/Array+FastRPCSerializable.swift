//
//  Array+FastRPCSerializable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

extension Array: FastRPCSerializable where Element: FastRPCSerializable {
    func serialize() throws -> Data {
        // Encode the size into bytes
        var size = count
        let sizeData = Data(bytes: &size, count: size.nonTrailingBytesCount)
        // Advance identifier by number of encoded size components
        var identifier = FastRPCObejectType.array.identifier + sizeData.count - 1
        let identifierData = Data(bytes: &identifier, count: identifier.nonTrailingBytesCount)
        // Buffer for final data
        var data = Data()

        // Convert each element into data
        let elementsData = try reduce(Data()) { partial, element -> Data in
            var data = partial

            data.append(try element.serialize())

            return data
        }

        // Build the final data structure
        data.append(identifierData)
        data.append(sizeData)
        data.append(elementsData)

        return data
    }
}
