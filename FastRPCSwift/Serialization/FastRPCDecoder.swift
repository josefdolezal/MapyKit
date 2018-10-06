//
//  FastRPCDecoder.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 06/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

public protocol FastRPCBinaryDecoder: Decoder {
    mutating func decode(_ type: Data.Type) throws -> Data
    mutating func decode(_ type: Date.Type) throws -> Date
}
