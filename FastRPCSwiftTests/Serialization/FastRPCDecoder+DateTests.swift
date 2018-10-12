//
//  FastRPCDecoder+DateTests.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 12/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class FastRPCDecoder_DateTests: XCTestCase {
    let decoder = FastRPCDecoder()

    func testDecodesDates() throws {
        for _ in 0 ... 100 {
            let date = Date(timeIntervalSince1970: TimeInterval(Int.random(in: 0 ... 2_000_000_000)))
            let data = try date.serialize().data

            XCTAssertEqual(try decoder.decode(Date.self, from: data), date)
        }
    }
}
