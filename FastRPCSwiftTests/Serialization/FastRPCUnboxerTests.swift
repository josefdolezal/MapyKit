//
//  FastRPCUnboxerTests.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 08/01/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class FastRPCUnboxerTests: XCTestCase {

    func testResponseUnbox() throws {
        // List all test files matching given pattern
        try bundledFiles().matching("response.*\\.frpc")
            // Read files content
            .map { try Data(contentsOf: $0) }
            // Unbox all test files
            .forEach { data in
                XCTAssertNoThrow(try FastRPCSerialization.object(with: data))
            }
    }

    func testProcedureUnbox() throws {
        try bundledFiles().matching("procedure.*\\.frpc")
            .map { try Data(contentsOf: $0) }
            .forEach { data in
                XCTAssertNoThrow(try FastRPCSerialization.object(with: data))
                print(try FastRPCSerialization.object(with: data))
            }
    }

}
