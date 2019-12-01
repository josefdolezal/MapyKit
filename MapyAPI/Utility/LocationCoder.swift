//
//  LocationCoder.swift
//  MapyAPI
//
//  Created by Josef Dolezal (Admin) on 01/12/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import Foundation

/// Provides API to convert GPS locations into string and back.
public enum LocationCoder {
    /// Serialization alphabet for converting number into string
    private static let alphabet = "0ABCD2EFGH4IJKLMN6OPQRST8UVWXYZ-1abcd3efgh5ijklmn7opqrst9uvwxyz."

    /// Turns sequence of locations into string representation.
    ///
    /// Note: Turning sequence of locations has different result than concatenation of string representation of single locations.
    ///
    /// - Parameter locations: Locations to be converted to string
    public static func stringify(_ locations: [Location]) -> String {
        locations.reduce((string: "", longitude: 0, latitude: 0)) { partial, location in
            var string = partial.string
            let longitude = Int(round((location.longitude + 180) * Double(1 << 28) / 360))
            let latitude = Int(round((location.latitude + 90) * Double(1 << 28) / 180))

            string += stringify(delta: longitude - partial.longitude, value: longitude)
            string += stringify(delta: latitude - partial.latitude, value: latitude)

            return (string, longitude, latitude)
        }.string
    }

    /// Serializes given coordinate into ASCII string. Given integer number is serialized using
    /// some kind of geohashing algorithm.
    ///
    /// Source: https://en.mapy.cz/js/userweb-c.js
    ///       Declared in methode `coordsToString(coords)`
    ///
    /// - Parameter coords: Coordinates to be serilized
    /// - Returns: Serialized coordinates
    private static func stringify(delta: Int, value: Int) -> String {
        var code = ""

        if delta >= -1024 && delta < 1024 {
            code.append(alphabet[(delta + 1024) >> 6])
            code.append(alphabet[(delta + 1024) & 63])
        } else if delta >= -32768 && delta < 32768 {
            let offset = 131072 | 1024 + 32768
            code.append(alphabet[(offset >> 12) & 63])
            code.append(alphabet[(offset >> 6) & 63])
            code.append(alphabet[offset & 63])
        } else {
            let offset = 805306368 | value & 268435455
            code.append(alphabet[(offset >> 24) & 63])
            code.append(alphabet[(offset >> 18) & 63])
            code.append(alphabet[(offset >> 12) & 63])
            code.append(alphabet[(offset >> 6) & 63])
            code.append(alphabet[offset & 63])
        }

        return code
    }
}

fileprivate extension String {
    /// Gets character at given index from string. Partial function, throws on
    /// out-of-range indexes.
    ///
    /// - Parameter index: Index of character to be returned
    subscript(_ index: Int) -> Character {
        return self[self.index(startIndex, offsetBy: index)]
    }
}
