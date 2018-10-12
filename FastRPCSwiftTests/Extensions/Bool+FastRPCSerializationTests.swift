//
//  Bool+FastRPCSerializationTests.swift
//  MapyAPITests
//
//  Created by Josef Dolezal on 18/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class Bool_FastRPCSerializationTests: XCTestCase {
    func testSerializeCorrectly() {
        XCTAssertEqual(try [UInt8](true.serialize().data), [17])
        XCTAssertEqual(try [UInt8](false.serialize().data), [16])
    }
}
