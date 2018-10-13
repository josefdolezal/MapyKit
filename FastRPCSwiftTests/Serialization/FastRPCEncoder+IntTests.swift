//
//  FastRPCEncoder+IntTests.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 12/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
import FastRPCSwift

class FastRPCEncoder_IntTests: XCTestCase {
    let encoder = FastRPCEncoder()

    func testSerializePositiveNumbers() {
        XCTAssertEqual([UInt8](try encoder.encode(500)), [57, 244, 1])
        XCTAssertEqual([UInt8](try encoder.encode(1000)), [57, 232, 3])
        XCTAssertEqual([UInt8](try encoder.encode(1500)), [57, 220, 5])
        XCTAssertEqual([UInt8](try encoder.encode(2000)), [57, 208, 7])
        XCTAssertEqual([UInt8](try encoder.encode(2500)), [57, 196, 9])
        XCTAssertEqual([UInt8](try encoder.encode(3000)), [57, 184, 11])
        XCTAssertEqual([UInt8](try encoder.encode(3500)), [57, 172, 13])
        XCTAssertEqual([UInt8](try encoder.encode(4000)), [57, 160, 15])
        XCTAssertEqual([UInt8](try encoder.encode(4500)), [57, 148, 17])
        XCTAssertEqual([UInt8](try encoder.encode(5000)), [57, 136, 19])
        XCTAssertEqual([UInt8](try encoder.encode(5500)), [57, 124, 21])
        XCTAssertEqual([UInt8](try encoder.encode(6000)), [57, 112, 23])
        XCTAssertEqual([UInt8](try encoder.encode(6500)), [57, 100, 25])
        XCTAssertEqual([UInt8](try encoder.encode(7000)), [57, 88, 27])
        XCTAssertEqual([UInt8](try encoder.encode(7500)), [57, 76, 29])
        XCTAssertEqual([UInt8](try encoder.encode(8000)), [57, 64, 31])
        XCTAssertEqual([UInt8](try encoder.encode(8500)), [57, 52, 33])
        XCTAssertEqual([UInt8](try encoder.encode(9000)), [57, 40, 35])
        XCTAssertEqual([UInt8](try encoder.encode(9500)), [57, 28, 37])
        XCTAssertEqual([UInt8](try encoder.encode(10000)), [57, 16, 39])
    }

    func testSerializeNegativeNumbers() {
        XCTAssertEqual([UInt8](try encoder.encode((-500))), [65, 244, 1])
        XCTAssertEqual([UInt8](try encoder.encode((-1000))), [65, 232, 3])
        XCTAssertEqual([UInt8](try encoder.encode((-1500))), [65, 220, 5])
        XCTAssertEqual([UInt8](try encoder.encode((-2000))), [65, 208, 7])
        XCTAssertEqual([UInt8](try encoder.encode((-2500))), [65, 196, 9])
        XCTAssertEqual([UInt8](try encoder.encode((-3000))), [65, 184, 11])
        XCTAssertEqual([UInt8](try encoder.encode((-3500))), [65, 172, 13])
        XCTAssertEqual([UInt8](try encoder.encode((-4000))), [65, 160, 15])
        XCTAssertEqual([UInt8](try encoder.encode((-4500))), [65, 148, 17])
        XCTAssertEqual([UInt8](try encoder.encode((-5000))), [65, 136, 19])
        XCTAssertEqual([UInt8](try encoder.encode((-5500))), [65, 124, 21])
        XCTAssertEqual([UInt8](try encoder.encode((-6000))), [65, 112, 23])
        XCTAssertEqual([UInt8](try encoder.encode((-6500))), [65, 100, 25])
        XCTAssertEqual([UInt8](try encoder.encode((-7000))), [65, 88, 27])
        XCTAssertEqual([UInt8](try encoder.encode((-7500))), [65, 76, 29])
        XCTAssertEqual([UInt8](try encoder.encode((-8000))), [65, 64, 31])
        XCTAssertEqual([UInt8](try encoder.encode((-8500))), [65, 52, 33])
        XCTAssertEqual([UInt8](try encoder.encode((-9000))), [65, 40, 35])
        XCTAssertEqual([UInt8](try encoder.encode((-9500))), [65, 28, 37])
        XCTAssertEqual([UInt8](try encoder.encode((-10000))), [65, 16, 39])
    }

    func testSerializeZero() {
        XCTAssertEqual([UInt8](try encoder.encode(0)), [56, 0])
    }
}
