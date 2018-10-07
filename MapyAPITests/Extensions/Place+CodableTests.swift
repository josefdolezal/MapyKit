//
//  Place+CodableTests.swift
//  MapyAPITests
//
//  Created by Josef Dolezal on 07/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
import Foundation
@testable import MapyAPI

class Place_CodableTests: XCTestCase {
    func testDecodesSingleObjectFromJSON() throws {
        let filemanager = FileManager.default
        let jsonDecoder = JSONDecoder()

        // Get all files from testing bundle
        let files = try filemanager.contentsOfDirectory(at: Bundle(for: type(of: self)).bundleURL, includingPropertiesForKeys: [.isRegularFileKey], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            // Get only json files with single place object
            .filter { $0.lastPathComponent.hasSuffix("place.json") }

        // Require at least one test to be run
        XCTAssertGreaterThan(files.count, 0)

        // Run test for each json file
        try files.forEach { file in
            let content = try Data(contentsOf: file)
            let place = try jsonDecoder.decode(Place.self, from: content)

            // Test empty properties to be nilled
            XCTAssertNil(place.zipCode)
            XCTAssertNil(place.landRegistryNumber)
            XCTAssertNil(place.houseNumber)
        }
    }

    func testDecodesCollectionFromJSON() throws {
        let filemanager = FileManager.default
        let jsonDecoder = JSONDecoder()

        // Get all files from testing bundle
        let files = try filemanager.contentsOfDirectory(at: Bundle(for: type(of: self)).bundleURL, includingPropertiesForKeys: [.isRegularFileKey], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            // Get only json files with single place object
            .filter { $0.lastPathComponent.hasSuffix("places.json") }

        // Require at least one test to be run
        XCTAssertGreaterThan(files.count, 0)

        // Run test for each json file
        try files.forEach { file in
            let content = try Data(contentsOf: file)

            XCTAssertNoThrow(try jsonDecoder.decode(Array<Place>.self, from: content)) { places in
                // Test empty properties to be nilled
                XCTAssertGreaterThan(places.count, 0)
            }
        }
    }
}

public func XCTAssertNoThrow<T>(_ expression: @autoclosure () throws -> T, _ message: String = "", file: StaticString = #file, line: UInt = #line, also validateResult: (T) -> Void) {
    func executeAndAssignResult(_ expression: @autoclosure () throws -> T, to: inout T?) rethrows {
        to = try expression()
    }
    var result: T?
    XCTAssertNoThrow(try executeAndAssignResult(expression, to: &result), message, file: file, line: line)
    if let r = result {
        validateResult(r)
    }
}
