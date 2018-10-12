//
//  FastRPCDecoder+BoolTests.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 12/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class FastRPCDecoder_BoolTests: XCTestCase {
    let decoder = FastRPCDecoder()

    func testDecodeCorrectly() throws {
        let decoder = FastRPCDecoder()

        try XCTAssertEqual(decoder.decode(Bool.self, from: true.serialize().data), true)
        try XCTAssertEqual(decoder.decode(Bool.self, from: false.serialize().data), false)
    }
}
