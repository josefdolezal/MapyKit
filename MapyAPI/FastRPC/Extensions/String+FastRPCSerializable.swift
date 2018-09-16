//
//  String+FastRPCSerializable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

extension String: FastRPCSerializable {
    func serialize() throws -> Data {
        // Try ot convert UTF8 string into data
        guard let data = data(using: .utf8) else {
            // Throw error on failure
            throw FastRPCError.serialization(self, nil)
        }

        // Return converted data
        return data
    }
}
