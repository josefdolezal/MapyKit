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
        let size = try self.count.serialize()
        // Advance identifier by number of encoded size components
        let identifier = FastRPCObejectType.array.identifier + size.count - 1
        // Buffer for final data
        var data = Data()

        // Convert each element into data
        let elementsData = try reduce(Data()) { partial, element -> Data in
            var data = partial

            data .append(try element.serialize())

            return partial
        }

        // Build the final data structure
        data.append(Data(identifier))
        data.append(size)
        data.append(elementsData)

        return data
    }
}
