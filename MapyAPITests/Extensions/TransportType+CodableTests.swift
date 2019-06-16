//
//  TransportType+CodableTests.swift
//  MapyAPITests
//
//  Created by Josef Dolezal on 13/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
import FastRPCSwift
@testable import MapyAPI

class TransportType_CodableTests: XCTestCase {
    let decoder = FastRPCDecoder()
    let encoder = FastRPCEncoder()

    func testCodable() throws {
        let all: [TransportType] = [
            .car(.fast), .car(.short), .bike(.mountain), .bike(.road),
            .foot(.short), .foot(.touristic), .skiing, .boat
        ]

        for type in all {
//            let data = try encoder.encode(type)
//            let subject = try decoder.decode(TransportType.self, from: data)
//
//            XCTAssertEqual(subject.identifier, type.identifier)
        }
    }
}
