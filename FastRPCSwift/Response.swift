//
//  Response.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 11/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Represents response for FRPC procedure call.
struct Response<Body: Decodable> {
    /// The response body
    public var body: Body
}

extension Response: Decodable {
    init(from decoder: Decoder) throws {
        self.body = try Body(from: decoder)
    }
}
