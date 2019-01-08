//
//  FastRPCDecoder+StringTests.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 12/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class FastRPCDecoder_StringTests: XCTestCase {
    private let decoder = FastRPCDecoder()

    func testDecodesRandomStrings() throws {
//        for _ in 0 ... 100 {
//            let length = Int.random(in: 0 ... 300)
//            let string = String.random(maxLength: length)
//            let data = try string.serialize().data
//
//            try XCTAssertEqual(decoder.decode(String.self, from: data), string)
//        }
    }

    func testDecodesEmptyString() throws {
//        let data = Data(bytes: [32, 0])
//        try XCTAssertEqual(decoder.decode(String.self, from: data), "")
    }
}
