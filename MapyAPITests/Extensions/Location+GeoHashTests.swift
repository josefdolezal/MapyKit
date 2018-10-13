//
//  Location+GeoHashTests.swift
//  MapyAPITests
//
//  Created by Josef Dolezal on 13/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import MapyAPI

class Location_GeoHashTests: XCTestCase {
    func testCreatesValidGeoHash() {
        XCTAssertEqual(Location(latitude: 14.304998517036438, longitude: 50.12692652642727).coordinatesGeoHash(), "9gjHQxY45C")
        XCTAssertEqual(Location(latitude: 14.311264157295227, longitude: 50.135097205638885).coordinatesGeoHash(), "9gkOQxYKgX")
        XCTAssertEqual(Location(latitude: 14.718333631753922, longitude: 50.596686601638794).coordinatesGeoHash(), "9htUAx-rjN")
        XCTAssertEqual(Location(latitude: 14.23854410648346, longitude: 48.60472932457924).coordinatesGeoHash(), "9g1CDxQ1XO")
        XCTAssertEqual(Location(latitude: 14.669371247291565, longitude: 48.60390655696392).coordinatesGeoHash(), "9hlZdxQ1HF")
        XCTAssertEqual(Location(latitude: 15.104377269744873, longitude: 47.429123148322105).coordinatesGeoHash(), "95y5nxKqVi")
        XCTAssertEqual(Location(latitude: 7.572121471166611, longitude: 46.3306874781847).coordinatesGeoHash(), "9RbYfxFd-6")
        XCTAssertEqual(Location(latitude: 7.450413554906845, longitude: 46.3284357637167).coordinatesGeoHash(), "9RJPfxFc5p")
        XCTAssertEqual(Location(latitude: 26.322762072086334, longitude: 45.53549565374851).coordinatesGeoHash(), "u4tvVxCByy")
        XCTAssertEqual(Location(latitude: 25.71641117334366, longitude: 45.51505118608475).coordinatesGeoHash(), "uHHavxBwad")
    }
}
