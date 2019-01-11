//
//  FastRPCBoxerTests.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 11/01/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class FastRPCBoxerTests: XCTestCase {

    func testFaultBox() throws {
        for _ in 0 ..< 20 {
            let fault = randomFault()
            let boxer = FastRPCBoxer(container: fault)

            XCTAssertNoThrow(try boxer.box())
        }
    }

    func testProcedureBox() throws {
        let tests: [(value: Int, encoded: [UInt8])] = [
            (500, [57, 244, 1]), (1000, [57, 232, 3]), (1500, [57, 220, 5]), (2000, [57, 208, 7]),
            (2500, [57, 196, 9]), (3000, [57, 184, 11]), (3500, [57, 172, 13]), (4000, [57, 160, 15]),
            (4500, [57, 148, 17]), (5000, [57, 136, 19]), (5500, [57, 124, 21]), (6000, [57, 112, 23]),
            (6500, [57, 100, 25]), (7000, [57, 88, 27]), (7500, [57, 76, 29]), (8000, [57, 64, 31]),
            (8500, [57, 52, 33]), (9000, [57, 40, 35]), (9500, [57, 28, 37]), (10000, [57, 16, 39])
        ]

        for test in tests {
            let boxer = FastRPCBoxer(container: UntypedProcedure(name: "c", arguments: [test.value]), version: .version2)

            print([0xca, 0x11])

            XCTAssertEqual(try [UInt8](boxer.box()), [0xCA, 0x11, 0x02, 0x00, 0x68, 0x01, 0x63] + test.encoded)
        }
    }

    private func randomFault() -> Fault {
        let code = Int.random(in: 0 ... .max)
        let message = String.random(maxLength: 20)

        return Fault(code: code, message: message)
    }
}
