//
//  Container+ConvenienceAPI.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 07/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
    /// Decodes string from container. When the string is presented but it's empty
    /// `nil` is returned. If the value is not presented, error is thrown.
    func decodeNonEmpty(_ type: String.Type, forKey key: Key) throws -> String? {
        // Try to decode string using standard API
        let value = try decode(String.self, forKey: key)

        // If the decoded string is empty, return nil
        return value.isEmpty
            ? nil
            : value
    }
}
