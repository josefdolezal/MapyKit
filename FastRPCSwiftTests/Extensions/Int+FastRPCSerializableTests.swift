//
//  Int+FastRPCSerializableTests.swift
//  MapyAPITests
//
//  Created by Josef Dolezal on 17/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class Int_FastRPCSerializableTests: XCTestCase {
    func testSerializePositiveNumbers() {
        XCTAssertEqual([UInt8](try 500.serialize().data), [57, 244, 1])
        XCTAssertEqual([UInt8](try 1000.serialize().data), [57, 232, 3])
        XCTAssertEqual([UInt8](try 1500.serialize().data), [57, 220, 5])
        XCTAssertEqual([UInt8](try 2000.serialize().data), [57, 208, 7])
        XCTAssertEqual([UInt8](try 2500.serialize().data), [57, 196, 9])
        XCTAssertEqual([UInt8](try 3000.serialize().data), [57, 184, 11])
        XCTAssertEqual([UInt8](try 3500.serialize().data), [57, 172, 13])
        XCTAssertEqual([UInt8](try 4000.serialize().data), [57, 160, 15])
        XCTAssertEqual([UInt8](try 4500.serialize().data), [57, 148, 17])
        XCTAssertEqual([UInt8](try 5000.serialize().data), [57, 136, 19])
        XCTAssertEqual([UInt8](try 5500.serialize().data), [57, 124, 21])
        XCTAssertEqual([UInt8](try 6000.serialize().data), [57, 112, 23])
        XCTAssertEqual([UInt8](try 6500.serialize().data), [57, 100, 25])
        XCTAssertEqual([UInt8](try 7000.serialize().data), [57, 88, 27])
        XCTAssertEqual([UInt8](try 7500.serialize().data), [57, 76, 29])
        XCTAssertEqual([UInt8](try 8000.serialize().data), [57, 64, 31])
        XCTAssertEqual([UInt8](try 8500.serialize().data), [57, 52, 33])
        XCTAssertEqual([UInt8](try 9000.serialize().data), [57, 40, 35])
        XCTAssertEqual([UInt8](try 9500.serialize().data), [57, 28, 37])
        XCTAssertEqual([UInt8](try 10000.serialize().data), [57, 16, 39])
    }

    func testSerializeNegativeNumbers() {
        XCTAssertEqual([UInt8](try (-500).serialize().data), [65, 244, 1])
        XCTAssertEqual([UInt8](try (-1000).serialize().data), [65, 232, 3])
        XCTAssertEqual([UInt8](try (-1500).serialize().data), [65, 220, 5])
        XCTAssertEqual([UInt8](try (-2000).serialize().data), [65, 208, 7])
        XCTAssertEqual([UInt8](try (-2500).serialize().data), [65, 196, 9])
        XCTAssertEqual([UInt8](try (-3000).serialize().data), [65, 184, 11])
        XCTAssertEqual([UInt8](try (-3500).serialize().data), [65, 172, 13])
        XCTAssertEqual([UInt8](try (-4000).serialize().data), [65, 160, 15])
        XCTAssertEqual([UInt8](try (-4500).serialize().data), [65, 148, 17])
        XCTAssertEqual([UInt8](try (-5000).serialize().data), [65, 136, 19])
        XCTAssertEqual([UInt8](try (-5500).serialize().data), [65, 124, 21])
        XCTAssertEqual([UInt8](try (-6000).serialize().data), [65, 112, 23])
        XCTAssertEqual([UInt8](try (-6500).serialize().data), [65, 100, 25])
        XCTAssertEqual([UInt8](try (-7000).serialize().data), [65, 88, 27])
        XCTAssertEqual([UInt8](try (-7500).serialize().data), [65, 76, 29])
        XCTAssertEqual([UInt8](try (-8000).serialize().data), [65, 64, 31])
        XCTAssertEqual([UInt8](try (-8500).serialize().data), [65, 52, 33])
        XCTAssertEqual([UInt8](try (-9000).serialize().data), [65, 40, 35])
        XCTAssertEqual([UInt8](try (-9500).serialize().data), [65, 28, 37])
        XCTAssertEqual([UInt8](try (-10000).serialize().data), [65, 16, 39])
    }

    func testSerializeZero() {
        XCTAssertEqual([UInt8](try 0.serialize().data), [56, 0])
    }
}
