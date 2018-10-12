//
//  Fault.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 11/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Represents FRPC call error response.
public struct Fault: Decodable {
    /// Error number
    public var code: Int
    /// Error description
    public var message: String
}
