//
//  Int+FastRPCSerializableTests.swift
//  MapyAPITests
//
//  Created by Josef Dolezal on 17/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import MapyAPI

class Int_FastRPCSerializableTests: XCTestCase {
    func testSerializePositiveNumbers() {
        XCTAssertEqual([UInt8](try 500.serialize()), [57, 244, 1])
        XCTAssertEqual([UInt8](try 1000.serialize()), [57, 232, 3])
        XCTAssertEqual([UInt8](try 1500.serialize()), [57, 220, 5])
        XCTAssertEqual([UInt8](try 2000.serialize()), [57, 208, 7])
        XCTAssertEqual([UInt8](try 2500.serialize()), [57, 196, 9])
        XCTAssertEqual([UInt8](try 3000.serialize()), [57, 184, 11])
        XCTAssertEqual([UInt8](try 3500.serialize()), [57, 172, 13])
        XCTAssertEqual([UInt8](try 4000.serialize()), [57, 160, 15])
        XCTAssertEqual([UInt8](try 4500.serialize()), [57, 148, 17])
        XCTAssertEqual([UInt8](try 5000.serialize()), [57, 136, 19])
        XCTAssertEqual([UInt8](try 5500.serialize()), [57, 124, 21])
        XCTAssertEqual([UInt8](try 6000.serialize()), [57, 112, 23])
        XCTAssertEqual([UInt8](try 6500.serialize()), [57, 100, 25])
        XCTAssertEqual([UInt8](try 7000.serialize()), [57, 88, 27])
        XCTAssertEqual([UInt8](try 7500.serialize()), [57, 76, 29])
        XCTAssertEqual([UInt8](try 8000.serialize()), [57, 64, 31])
        XCTAssertEqual([UInt8](try 8500.serialize()), [57, 52, 33])
        XCTAssertEqual([UInt8](try 9000.serialize()), [57, 40, 35])
        XCTAssertEqual([UInt8](try 9500.serialize()), [57, 28, 37])
        XCTAssertEqual([UInt8](try 10000.serialize()), [57, 16, 39])
    }
}
