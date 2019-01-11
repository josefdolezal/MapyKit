//
//  FastRPCEncoder+DataTests.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 13/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class FastRPCEncoder_DataTests: XCTestCase {
    let encoder = FastRPCEncoder()

    func testSerializeRawData() {
        // Run random tests
        for _ in 0..<10 {
            // Create random bytes sequence
//            let bytes = (0..<Int.random(in: 1...15)).map { _ in UInt8.random(in: 0...255) }
//            let identifier = UInt8(FastRPCObejectType.binary.identifier + bytes.count.nonTrailingBytesCount - 1)
//            let data = Data(bytes: bytes)
//
//            XCTAssertEqual(try [UInt8](encoder.encode(data)), [identifier, UInt8(bytes.count)] + bytes)
        }
    }
}
