//
//  Array+FastRPCSerializable.swift
//  MapyAPITests
//
//  Created by Josef Dolezal on 18/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import MapyAPI

class Array_FastRPCSerializable: XCTestCase {
    func testSerializeCollectionOfInts() {
        XCTAssertEqual(try [UInt8]([Int]().serialize()), [88, 0])
        XCTAssertEqual(try [UInt8]([6874, 4320, 1990, 7980, 9221, 5189, 3599].serialize()), [88, 7, 57, 218, 26, 57, 224, 16, 57, 198, 7, 57, 44, 31, 57, 5, 36, 57, 69, 20, 57, 15, 14])
        XCTAssertEqual(try [UInt8]([9817, 1946, 2691, 5063, 8619, 9597, 2246].serialize()), [88, 7, 57, 89, 38, 57, 154, 7, 57, 131, 10, 57, 199, 19, 57, 171, 33, 57, 125, 37, 57, 198, 8])
        XCTAssertEqual(try [UInt8]([3331].serialize()), [88, 1, 57, 3, 13])
        XCTAssertEqual(try [UInt8]([370, 4399, 4635, 4747, 8109, 9011, 8616, 2583, 6801, 3030].serialize()), [88, 10, 57, 114, 1, 57, 47, 17, 57, 27, 18, 57, 139, 18, 57, 173, 31, 57, 51, 35, 57, 168, 33, 57, 23, 10, 57, 145, 26, 57, 214, 11])
        XCTAssertEqual(try [UInt8]([1683, 7446, 5923, 4321, 9780, 4009, 9871, 6786, 2931].serialize()), [88, 9, 57, 147, 6, 57, 22, 29, 57, 35, 23, 57, 225, 16, 57, 52, 38, 57, 169, 15, 57, 143, 38, 57, 130, 26, 57, 115, 11])
        XCTAssertEqual(try [UInt8]([1898, 8798, 5812, 8284, 4208].serialize()), [88, 5, 57, 106, 7, 57, 94, 34, 57, 180, 22, 57, 92, 32, 57, 112, 16])
        XCTAssertEqual(try [UInt8]([4225, 245, 3702, 7605, 279, 2469, 3432].serialize()), [88, 7, 57, 129, 16, 56, 245, 57, 118, 14, 57, 181, 29, 57, 23, 1, 57, 165, 9, 57, 104, 13])
        XCTAssertEqual(try [UInt8]([4824].serialize()), [88, 1, 57, 216, 18])
        XCTAssertEqual(try [UInt8]([4739, 4979, 9448, 823].serialize()), [88, 4, 57, 131, 18, 57, 115, 19, 57, 232, 36, 57, 55, 3])
    }
}
