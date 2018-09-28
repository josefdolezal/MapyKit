//
//  LocationTests.swift
//  MapyAPITests
//
//  Created by Josef Dolezal on 28/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift
@testable import MapyAPI

class Location_FastRPCSerializableTests: XCTestCase {
    func testLocationSerialize() throws {
        XCTAssertEqual(try [UInt8](Location(latitude: 14.304998517036438, longitude: 50.12692652642727).serialize().data), try [UInt8]("9gjHQxY45C".serialize().data))
        XCTAssertEqual(try [UInt8](Location(latitude: 14.311264157295227, longitude: 50.135097205638885).serialize().data), try [UInt8]("9gkOQxYKgX".serialize().data))
        XCTAssertEqual(try [UInt8](Location(latitude: 14.718333631753922, longitude: 50.596686601638794).serialize().data), try [UInt8]("9htUAx-rjN".serialize().data))
        XCTAssertEqual(try [UInt8](Location(latitude: 14.23854410648346, longitude: 48.60472932457924).serialize().data), try [UInt8]("9g1CDxQ1XO".serialize().data))
        XCTAssertEqual(try [UInt8](Location(latitude: 14.669371247291565, longitude: 48.60390655696392).serialize().data), try [UInt8]("9hlZdxQ1HF".serialize().data))
        XCTAssertEqual(try [UInt8](Location(latitude: 15.104377269744873, longitude: 47.429123148322105).serialize().data), try [UInt8]("95y5nxKqVi".serialize().data))
        XCTAssertEqual(try [UInt8](Location(latitude: 7.572121471166611, longitude: 46.3306874781847).serialize().data), try [UInt8]("9RbYfxFd-6".serialize().data))
        XCTAssertEqual(try [UInt8](Location(latitude: 7.450413554906845, longitude: 46.3284357637167).serialize().data), try [UInt8]("9RJPfxFc5p".serialize().data))
        XCTAssertEqual(try [UInt8](Location(latitude: 26.322762072086334, longitude: 45.53549565374851).serialize().data), try [UInt8]("u4tvVxCByy".serialize().data))
        XCTAssertEqual(try [UInt8](Location(latitude: 25.71641117334366, longitude: 45.51505118608475).serialize().data), try [UInt8]("uHHavxBwad".serialize().data))
    }
}
