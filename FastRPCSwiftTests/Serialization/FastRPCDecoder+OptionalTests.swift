//
//  FastRPCDecoder+OptionalTests.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 12/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class FastRPCDecoder_OptionalTests: XCTestCase {
    let decoder = FastRPCDecoder()

    func testDecodesOptionals() throws {
        XCTAssertEqual(try decoder.decode(Int?.self, from: Optional<Int>.none.serialize().data), Optional<Int>.none)
        XCTAssertEqual(try decoder.decode(String?.self, from: Optional<String>.none.serialize().data), Optional<String>.none)
        XCTAssertEqual(try decoder.decode(Double?.self, from: Optional<Double>.none.serialize().data), Optional<Double>.none)
        XCTAssertEqual(try decoder.decode(Bool?.self, from: Optional<Bool>.none.serialize().data), Optional<Bool>.none)
        XCTAssertEqual(try decoder.decode(Date?.self, from: Optional<Date>.none.serialize().data), Optional<Date>.none)
        XCTAssertEqual(try decoder.decode(Data?.self, from: Optional<Data>.none.serialize().data), Optional<Data>.none)
    }
}
