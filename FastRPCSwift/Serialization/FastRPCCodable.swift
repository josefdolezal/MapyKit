//
//  FastRPC+Codable.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 06/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

typealias FastRPCCodable = FastRPCEncodable & FastRPCDecodable

public protocol FastRPCEncodable: Encodable {
    func frpcEncode(to encoder: FastRPCBinaryEncoder) throws
}

public protocol FastRPCDecodable: Decodable {
    init(fromFrpc decoder: FastRPCBinaryDecoder) throws
}

extension FastRPCEncodable {
    func frpcEncode(to encoder: FastRPCBinaryEncoder) throws {
        try encode(to: encoder)
    }
}

public extension FastRPCDecodable {
    init(fromFrpc decoder: FastRPCBinaryDecoder) throws {
        try self.init(from: decoder)
    }
}
