//
//  FastRPCEncoder+DateTests.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 13/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
import FastRPCSwift

class FastRPCEncoder_DateTests: XCTestCase {
    let encoder = FastRPCEncoder()

    func testSerializeDate() {
        XCTAssertEqual(try [UInt8](encoder.encode(Date(timeIntervalSince1970: 1537391055))), [40, 248, 207, 185, 162, 91, 123, 136, 59, 83, 52])
        XCTAssertEqual(try [UInt8](encoder.encode(Date(timeIntervalSince1970: 1537391056))), [40, 248, 208, 185, 162, 91, 131, 136, 59, 83, 52])
        XCTAssertEqual(try [UInt8](encoder.encode(Date(timeIntervalSince1970: 1537391057))), [40, 248, 209, 185, 162, 91, 139, 136, 59, 83, 52])
        XCTAssertEqual(try [UInt8](encoder.encode(Date(timeIntervalSince1970: 1537391058))), [40, 248, 210, 185, 162, 91, 147, 136, 59, 83, 52])
        XCTAssertEqual(try [UInt8](encoder.encode(Date(timeIntervalSince1970: 1537391059))), [40, 248, 211, 185, 162, 91, 155, 136, 59, 83, 52])
        XCTAssertEqual(try [UInt8](encoder.encode(Date(timeIntervalSince1970: 1537391060))), [40, 248, 212, 185, 162, 91, 163, 136, 59, 83, 52])
        XCTAssertEqual(try [UInt8](encoder.encode(Date(timeIntervalSince1970: 1537391061))), [40, 248, 213, 185, 162, 91, 171, 136, 59, 83, 52])
        XCTAssertEqual(try [UInt8](encoder.encode(Date(timeIntervalSince1970: 1537391062))), [40, 248, 214, 185, 162, 91, 179, 136, 59, 83, 52])
        XCTAssertEqual(try [UInt8](encoder.encode(Date(timeIntervalSince1970: 1537391063))), [40, 248, 215, 185, 162, 91, 187, 136, 59, 83, 52])
        XCTAssertEqual(try [UInt8](encoder.encode(Date(timeIntervalSince1970: 1537391064))), [40, 248, 216, 185, 162, 91, 195, 136, 59, 83, 52])
    }
}
