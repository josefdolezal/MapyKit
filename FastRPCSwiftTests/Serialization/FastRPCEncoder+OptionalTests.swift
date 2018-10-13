//
//  FastRPCEncoder+OptionalTests.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 13/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
import FastRPCSwift

class FastRPCEncoder_OptionalTests: XCTestCase {
    let encoder = FastRPCEncoder()

    func testSerializeNilValue() {
        XCTAssertEqual(try [UInt8](encoder.encode(Optional<Int>.none)), [0x60])
    }

    func testSerializeSomeValue() {
        XCTAssertEqual(try [UInt8](encoder.encode(Optional.some("ěřADčéó#$Aů"))), [32, 17, 196, 155, 197, 153, 65, 68, 196, 141, 195, 169, 195, 179, 35, 36, 65, 197, 175])
        XCTAssertEqual(try [UInt8](encoder.encode(Optional.some(true))), [17])
        XCTAssertEqual(try [UInt8](encoder.encode(Optional.some(false))), [16])
        XCTAssertEqual(try [UInt8](encoder.encode(Optional.some(5343))), [57, 223, 20])
        XCTAssertEqual(try [UInt8](encoder.encode(Optional.some(14.324434293515196))), [24, 0x80, 0xB2, 0x70, 0x40, 0x1C, 0xA6, 0x2C, 0x40])
    }
}
