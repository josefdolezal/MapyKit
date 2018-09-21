//
//  Bool+FastRPCSerializable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

extension Bool: FastRPCSerializable {
    public func serialize() throws -> SerializationBuffer {
        let identifier = FastRPCObejectType.bool.identifier

        // Increase identifier if current value is `true`
        var data = self
            ? identifier + 1
            : identifier

        // Serialize identifier
        return SerializationBuffer(data: Data(bytes: &data, count: 1))
    }
}
