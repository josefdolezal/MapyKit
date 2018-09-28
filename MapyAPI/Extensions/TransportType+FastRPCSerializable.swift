//
//  TransportType+FastRPCSerializable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 28/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import FastRPCSwift

extension TransportType: FastRPCSerializable {
    public func serialize() throws -> SerializationBuffer {
        return try identifier.serialize()
    }
}
