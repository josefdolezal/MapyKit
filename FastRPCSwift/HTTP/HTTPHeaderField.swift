//
//  HTTPHeaderField.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 23/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Statically typed HTTP headers.
enum HTTPHeaderField {
    /// Accepted response content type
    case accept(HTTPContentType)
    /// Request content type
    case contentType(HTTPContentType)

    // MARK: Internal API

    /// The header key
    fileprivate var header: String {
        return data.header
    }

    /// The header value
    fileprivate var value: String {
        return data.value
    }

    // MARK: Private API

    /// Internal shorthand for request header data
    private var data: (header: String, value: String) {
        switch self {
        case let .accept(type): return ("Accept", type.header)
        case let .contentType(type): return ("Content-Type", type.header)
        }
    }
}

extension URLRequest {
    /// Sets statically typed HTTP header field.
    ///
    /// - Parameter header: The header field to be set
    mutating func addHeader(_ header: HTTPHeaderField) {
        addValue(header.value, forHTTPHeaderField: header.header)
    }
}
