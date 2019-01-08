//
//  FastRPCDecoder+IntTests.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 12/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class FastRPCDecoder_IntTests: XCTestCase {
    let decoder = FastRPCDecoder()

    func testDecodePositiveNumbers() throws {
//        let decoder = FastRPCDecoder()
//
//        for _ in 0...100 {
//            let subject = Int(Int32.random(in: 0 ... .max))
//            let encoded = try subject.serialize().data
//
//            try XCTAssertEqual(decoder.decode(Int.self, from: encoded), subject)
//        }
//
//        try XCTAssertEqual(decoder.decode(Int.self, from: 0.serialize().data), 0)
    }

    func testDecodeNegativeNumbers() throws {
//        let decoder = FastRPCDecoder()
//
//        for _ in 0...100 {
//            let subject = Int(Int32.random(in: .min ..< 0))
//            let encoded = try subject.serialize().data
//
//            try XCTAssertEqual(decoder.decode(Int.self, from: encoded), subject)
//        }
    }
}
