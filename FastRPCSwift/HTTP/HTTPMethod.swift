//
//  HTTPMethod.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 23/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// HTTP request methods.
enum HTTPMethod: String {
    /// HTTP POST method
    case post

    /// Method type used for HTTP headers
    var type: String { return rawValue.uppercased() }
}
