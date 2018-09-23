//
//  Dictionary+FastRPCSerializableTests.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 23/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class Dictionary_FastRPCSerializableTests: XCTestCase {
    func testSerializeDictionary() {
        XCTAssertEqual(try [UInt8](["a": ["b": ["c": 1000]]].serialize().data), [80, 1, 1, 97, 80, 1, 1, 98, 80, 1, 1, 99, 57, 232, 3])
    }
}
