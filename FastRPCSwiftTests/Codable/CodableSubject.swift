//
//  CodableSubject.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 18/01/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

@testable import FastRPCSwift

struct CodableSubject: Codable {
    private enum CodingKeys: String, CodingKey {
        case number, floating, string, nested
    }

    struct NestedClass: Codable {
        private enum CodingKeys: String, CodingKey {
            case number, numbers, floating, floatings, string, strings
        }

        let number: Int
        let numbers: [Int]
        let floating: Double
        let floatings: [Double]
        let string: String
        let strings: [String]

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            number = try container.decode(Int.self, forKey: .number)
            numbers = try container.decode([Int].self, forKey: .numbers)
            floating = try container.decode(Double.self, forKey: .floating)
            floatings = try container.decode([Double].self, forKey: .floatings)
            string = try container.decode(String.self, forKey: .string)
            strings = try container.decode([String].self, forKey: .strings)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(number, forKey: .number)
            try container.encode(numbers, forKey: .numbers)
            try container.encode(floating, forKey: .floating)
            try container.encode(floatings, forKey: .floatings)
            try container.encode(string, forKey: .string)
            try container.encode(strings, forKey: .strings)
        }
    }

    let number: Int
    let floating: Double
    let string: String
    let nested: NestedClass

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        number = try container.decode(Int.self, forKey: .number)
        floating = try container.decode(Double.self, forKey: .floating)
        string = try container.decode(String.self, forKey: .string)
        nested = try container.decode(NestedClass.self, forKey: .nested)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(number, forKey: .number)
        try container.encode(floating, forKey: .floating)
        try container.encode(string, forKey: .string)
        try container.encode(nested, forKey: .nested)
    }
}
