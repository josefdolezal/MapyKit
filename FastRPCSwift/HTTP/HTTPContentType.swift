//
//  HTTPContentType.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 23/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Supported HTML content types.
enum HTTPContentType {
    /// FastRPC serialized data encoded using base64
    case base64frpc

    /// The type header value
    var header: String {
        switch self {
        case .base64frpc: return "application/x-base64-frpc"
        }
    }
}
