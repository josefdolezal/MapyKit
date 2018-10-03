//
//  String+Random.swift
//  FastRPCSwiftTests
//
//  Created by Josef Dolezal on 03/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

extension String {
    static func random(maxLength: Int) -> String {
        guard maxLength > 0 else { return "" }

        let chars = (0...maxLength)
            .map { _ -> Character in
                let char = UInt8.random(in: .min ... .max)

                return Character(Unicode.Scalar(char))
        }

        return String(chars)
    }
}
