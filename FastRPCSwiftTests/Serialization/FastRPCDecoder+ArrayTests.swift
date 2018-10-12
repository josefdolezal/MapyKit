//
//  FastRPCDecoder+ArrayTests.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 12/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class FastRPCDecoder_ArrayTests: XCTestCase {
    let decoder = FastRPCDecoder()

    func testDecodesIntArray() throws {
        for _ in 0 ... 100 {
            let array = [Int].random(count: .random(in: 0 ..< 50)) { Int(Int32.random(in: .min ... .max)) }
            let data = try array.serialize().data

            XCTAssertEqual(try decoder.decode([Int].self, from: data), array)
        }
    }

    func testDecodesStringArray() throws {
        for _ in 0 ... 100 {
            let stringGenerator: () -> String = {
                let size = Int(Int32.random(in: 0 ... 70))

                return String.random(maxLength: size)
            }

            let array = [String].random(count: .random(in: 0 ..< 50), generator: stringGenerator)
            let data = try array.serialize().data

            XCTAssertEqual(try decoder.decode([String].self, from: data), array)
        }
    }

    func testDecodesBoolArray() throws {
        for _ in 0 ... 100 {
            let array = [Bool].random(count: .random(in: 0 ..< 500)) { Bool.random() }
            let data = try array.serialize().data

            XCTAssertEqual(try decoder.decode([Bool].self, from: data), array)
        }
    }

    func testDecodesDoubleArray() throws {
        for _ in 0 ... 100 {
            let array = [Double].random(count: .random(in: 0 ..< 50)) { Double.random(in: -999_999 ... 999_999) }
            let data = try array.serialize().data

            XCTAssertEqual(try decoder.decode([Double].self, from: data), array)
        }
    }
}
