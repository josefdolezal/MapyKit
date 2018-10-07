//
//  Asserts.swift
//  MapyKit
//
//  Created by Josef Dolezal on 07/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest

/// Custom assertion for non throwing expression. If the expression not trhow, additional tests on it.
public func XCTAssertNoThrow<T>(_ expression: @autoclosure () throws -> T, _ message: String = "", file: StaticString = #file, line: UInt = #line, tests: (T) -> Void) {
    func executeAndAssignResult(_ expression: @autoclosure () throws -> T, to: inout T?) rethrows {
        to = try expression()
    }

    var result: T?

    XCTAssertNoThrow(try executeAndAssignResult(expression, to: &result), message, file: file, line: line)
    
    if let r = result {
        tests(r)
    }
}
