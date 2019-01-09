//
//  Procedure.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 09/01/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import Foundation

class UntypedProcedure: CustomStringConvertible {
    var name: String
    var arguments: [Any]

    var description: String {
        return "\(type(of: self)) =\t{\n\tname =\t\(name)\n\targuments =\t\(arguments)"
    }

    init(name: String, arguments: [Any]) {
        self.name = name
        self.arguments = arguments
    }
}

public struct Procedure1<Arg: Codable>: Codable {
    var name: String
    var arg: Arg

    public init(name: String, arg: Arg) {
        self.name = name
        self.arg = arg
    }

    public init(from decoder: Decoder) throws {
        // Due to limitations of type system, we do not support 3rd party decoders
        guard let decoder = decoder as? _FastRPCDecoder else {
            assertionFailure("FastRPC Procedure is only decodable from internal FastRPCDecoder.")
            #warning("Should not fatal error here")
            fatalError()
        }

        // Decode procedure as temporary variable and initialize `self` using this var.
        // This workaround due to usage of [Any] as arguments list, the initializer cannot
        // be synthetized by compiler.
        var container = try decoder.procedureContainer()

        self.name = try container.decode(String.self)
        self.arg = try container.decode(Arg.self)
    }

    public func encode(to encoder: Encoder) throws {
        // Due to limitations of type system, we do not support 3rd party encoders.
        // This workaround due to usage of [Any] as arguments list, the encoding method cannot
        // be synthetized by compiler.
        assert(encoder is _FastRPCEncoder, "FastRPC Procedure is only encodable using internal FastRPCEncoder.")

        var container = encoder.unkeyedContainer()

        try container.encode(self)
    }
}

public struct Procedure2<Arg1: Codable, Arg2: Codable>: Codable {
    var name: String
    var arg1: Arg1
    var arg2: Arg2

    public init(name: String, arg1: Arg1, arg2: Arg2) {
        self.name = name
        self.arg1 = arg1
        self.arg2 = arg2
    }

    public init(drom decoder: Decoder) throws {
        // Due to limitations of type system, we do not support 3rd party decoders
        guard let decoder = decoder as? _FastRPCDecoder else {
            assertionFailure("FastRPC Procedure is only decodable from internal FastRPCDecoder.")
            #warning("Should not fatal error here")
            fatalError()
        }

        var container = try decoder.procedureContainer()

        self.name = try container.decode(String.self)
        self.arg1 = try container.decode(Arg1.self)
        self.arg2 = try container.decode(Arg2.self)
    }

    #warning("Implement procedure encoding")
}
