//
//  ArbitraryObject+FastRPCSerializableTests.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 03/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class ArbitraryObject_FastRPCSerializableTests: XCTestCase {

    // Arbitrary object with single value (representing data primitive)
    private struct PlainObject<T: Decodable & Equatable>: Decodable, Equatable {
        var value: T

        init(value: T) {
            self.value = value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            self.value = try container.decode(T.self)
        }
    }

    private typealias IntObject = PlainObject<Int>
    private typealias StringObject = PlainObject<String>
    private typealias BoolObject = PlainObject<Bool>
    private typealias DoubleObject = PlainObject<Double>

    private let decoder = FastRPCDecoder()

    func testDecodesPlainObjects() throws {
        for _ in 0 ... 100 {
            let int = Int.random(in: 0 ... .max)
            let intData = try int.serialize().data
            let string = String.random(maxLength: Int.random(in: 1 ... 200))
            let stringData = try string.serialize().data
            let bool = Bool.random()
            let boolData = try bool.serialize().data
            let double = Double.random(in: -10_000 ... 10_000)
            let doubleData = try double.serialize().data

            try XCTAssertEqual(decoder.decode(IntObject.self, from: intData), IntObject(value: int))
            try XCTAssertEqual(decoder.decode(StringObject.self, from: stringData), StringObject(value: string))
            try XCTAssertEqual(decoder.decode(BoolObject.self, from: boolData), BoolObject(value: bool) )
            try XCTAssertEqual(decoder.decode(DoubleObject.self, from: doubleData), DoubleObject(value: double))
        }
    }
}
