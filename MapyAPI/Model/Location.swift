//
//  Location.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 24/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import FastRPCSwift

/// Represents GPS location coordinations.
public struct Location: FastRPCSerializable {
    // MARK: Properties

    /// Coordinations latitude
    public var latitude: Double
    /// Coordinations longitude
    public var longitude: Double

    /// Serialization alphabet for converting number into string
    private static let alphabet = "0ABCD2EFGH4IJKLMN6OPQRST8UVWXYZ-1abcd3efgh5ijklmn7opqrst9uvwxyz."

    // MARK: FastRPCSerializable

    public func serialize() throws -> SerializationBuffer {
        // Prepare coordinates for serialization
        let x = Int(latitude + 180) * (1 << 28) / 360
        let y = Int(longitude + 90) * (1 << 28) / 180

        // Serialize each coordiante separately, merge the result
        let encoded = Location.serialize(coords: x) + Location.serialize(coords: y)

        // Serialize coordinates result
        return try encoded.serialize()
    }

    // MARK: Private API

    /// Serializes given coordinate into ASCII string.
    ///
    /// - Parameter coords: Coordinates to be serilized
    /// - Returns: Serialized coordinates
    private static func serialize(coords: Int) -> String {
        var code = ""

        if coords >= -1024 && coords < 1024 {

        } else if coords >= -32768 && coords < 32768 {

        } else {

        }

        return code
    }
}

//var code = "";
//if (delta >= -1024 && delta < 1024) {
//    code += ALPHABET.charAt(delta + 1024 >> 6);
//    code += ALPHABET.charAt(delta + 1024 & 63)
//} else if (delta >= -32768 && delta < 32768) {
//    var value = 131072 | delta + 32768;
//    code += ALPHABET.charAt(value >> 12 & 63);
//    code += ALPHABET.charAt(value >> 6 & 63);
//    code += ALPHABET.charAt(value & 63)
//} else {
//    var _value = 805306368 | orig & 268435455;
//    code += ALPHABET.charAt(_value >> 24 & 63);
//    code += ALPHABET.charAt(_value >> 18 & 63);
//    code += ALPHABET.charAt(_value >> 12 & 63);
//    code += ALPHABET.charAt(_value >> 6 & 63);
//    code += ALPHABET.charAt(_value & 63)
//}
