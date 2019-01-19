//
//  FastRPCDecoderTests.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 18/01/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class FastRPCDecoderTests: XCTestCase {
    func testDecodesSubject() throws {
        let decoder = FastRPCDecoder()

        // List all test files matching given pattern
        try bundledFiles().matching("response-codable-subject.*\\.frpc")
            // Read files content
            .map { try Data(contentsOf: $0) }
            // Unbox all test files
            .forEach { data in
                XCTAssertNoThrow(try decoder.decode(Response<CodableSubject>.self, from: data))
            }
    }
}
