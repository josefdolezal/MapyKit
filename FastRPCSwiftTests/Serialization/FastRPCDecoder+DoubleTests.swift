//
//  FastRPCDecoder+DoubleTests.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 12/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class FastRPCDecoder_DoubleTests: XCTestCase {
    let decoder = FastRPCDecoder()

    func testDecodesPositiveNumbers() throws {
        for _ in 0 ... 100 {
            let subject = Double.random(in: 0 ... 10_000)
            let data = try subject.serialize().data

            try XCTAssertEqual(decoder.decode(Double.self, from: data), subject)
        }
    }

    func testDecodesNegativeNumbers() throws {
        for _ in 0 ... 100 {
            let subject = Double.random(in: -10_000 ..< 0)
            let data = try subject.serialize().data

            try XCTAssertEqual(decoder.decode(Double.self, from: data), subject)
        }
    }

    func testDecodesSpecialCases() {
        try XCTAssertEqual(decoder.decode(Double.self, from: (0.0).serialize().data), 0.0)
    }
}
