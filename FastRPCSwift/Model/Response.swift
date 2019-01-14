//
//  Response.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 09/01/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import Foundation

public class UntypedResponse: CustomStringConvertible {
    public var value: Any

    public var description: String {
        return "\(type(of: self)) =\t\(value)"
    }

    public init(value: Any) {
        self.value = value
    }
}

public struct Response<Value: Codable>: Decodable {
    public var value: Value

    public init(value: Value) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        fatalError()
    }

    public func encode(to encoder: Encoder) throws {
        guard let encoder = encoder as? FastRPCResponseEncoder else {
            #warning("Implement response encoding")
            fatalError()
        }

        var container = encoder.responseContainer()

        try container.encode(value)
    }
}
