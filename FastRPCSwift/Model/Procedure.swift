//
//  Procedure.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 09/01/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import Foundation

public class UntypedProcedure: CustomStringConvertible {
    public var name: String
    public var arguments: [Any]

    public var description: String {
        return "\(type(of: self)) =\t{\n\tname =\t\(name)\n\targuments =\t\(arguments)"
    }

    public init(name: String, arguments: [Any]) {
        self.name = name
        self.arguments = arguments
    }
}

public struct Procedure1<Arg: Codable>: Codable {
    public var name: String
    public var arg: Arg

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
        guard var encoder = encoder as? FastRPCProcedureEncoder else {
            #warning("FastRPC Procedure is only encodable using internal FastRPCEncoder.")
            fatalError()
        }

        var container = encoder.procedureContainer()

        try container.encodeName(name)
        try container.encode(arg)
    }
}

public struct Procedure2<Arg1: Codable, Arg2: Codable>: Codable {
    public var name: String
    public var arg1: Arg1
    public var arg2: Arg2

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

    public func encode(to encoder: Encoder) throws {
        guard let encoder = encoder as? FastRPCProcedureEncoder else {
            #warning("throw an error")
            fatalError()
        }

        var container = encoder.procedureContainer()

        try container.encodeName(name)
        try container.encode(arg1)
        try container.encode(arg2)
    }
}
