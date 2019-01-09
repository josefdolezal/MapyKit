//
//  Response.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 09/01/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import Foundation

class UntypedResponse: Codable, CustomStringConvertible {
    var value: Any

    var description: String {
        return "\(type(of: self)) =\t\(value)"
    }

    init(value: Any) {
        self.value = value
    }

    required init(from decoder: Decoder) throws {
        assert(decoder is FastRPCDecoder, "FastRPC Response is only decodable from internal FastRPCDecoder.")

        let container = try decoder.singleValueContainer()
        let response = try container.decode(UntypedResponse.self)

        self.value = response.value
    }

    func encode(to encoder: Encoder) throws {
        assert(encoder is FastRPCEncoder, "FastRPC Response is only encodable using internal FastRPCEncoder.")

        var container = encoder.singleValueContainer()

        try container.encode(self)
    }
}

public struct Response<Value: Decodable>: Decodable {
    public var value: Value

    public init(value: Value) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        fatalError()
    }

    public func encode(to encoder: Encoder) throws {
        #warning("Implement response encoding")
        fatalError()
    }
}
