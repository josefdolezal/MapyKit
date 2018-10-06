//
//  FastRPCEncoder.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 06/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

public protocol FastRPCBinaryEncoder: Encoder {
    mutating func encode(_ value: Data) throws
    mutating func encode(_ value: Date) throws
}
