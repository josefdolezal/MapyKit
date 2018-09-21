//
//  Optional+FastRPCSerializable.swift
//  MapyAPITests
//
//  Created by Josef Dolezal on 18/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class Optional_FastRPCSerializable: XCTestCase {
    func testSerializeNilValue() {
        XCTAssertEqual(try [UInt8](Optional<Int>.none.serialize().data), [0x60])
    }

    func testSerializeSomeValue() {
        XCTAssertEqual(try [UInt8](Optional.some("ěřADčéó#$Aů").serialize().data), [32, 17, 196, 155, 197, 153, 65, 68, 196, 141, 195, 169, 195, 179, 35, 36, 65, 197, 175])
        XCTAssertEqual(try [UInt8](Optional.some(true).serialize().data), [17])
        XCTAssertEqual(try [UInt8](Optional.some(false).serialize().data), [16])
        XCTAssertEqual(try [UInt8](Optional.some(5343).serialize().data), [57, 223, 20])
        XCTAssertEqual(try [UInt8](Optional.some(14.324434293515196).serialize().data), [24, 0x80, 0xB2, 0x70, 0x40, 0x1C, 0xA6, 0x2C, 0x40])
    }
}
