//
//  FastRPCDecoder+DataTests.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 12/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class FastRPCDecoder_DataTests: XCTestCase {
    let decoder = FastRPCDecoder()

    func testDecodesRawData() throws {
        for _ in 0 ... 100 {
            let bytes = [UInt8].random(count: .random(in: 0 ... 200)) { UInt8.random(in: 0 ... 255) }
            let subject = Data(bytes: bytes)
            let data = try subject.serialize().data

            XCTAssertEqual(try decoder.decode(Data.self, from: data), subject)
        }
    }

}
