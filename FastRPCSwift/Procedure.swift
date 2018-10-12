//
//  Procedure.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 21/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Represents remote procedure without arguments.
public struct Procedure0: Codable {
    public var name: String

    public init(name: String) {
        self.name = name
    }
}

/// Represents remote procedure. Is called with serialized `parameters`.
public struct Procedure1<A: Codable> {
    // MARK: Properties

    /// The procedure name
    public var name: String
    /// First procedure parameter
    public var a: A

    // MARK: Initializers

    /// Creates new remote procedure representation. Procedure may be called using `FastRPCService`.
    ///
    /// - Parameters:
    ///   - name: Name of remote procedure
    ///   - parameters: Remote procedure parameters
    public init(name: String, _ a: A) {
        self.name = name
        self.a = a
    }
}

extension Procedure1: Codable {
    private enum CodingKeys: String, CodingKey {
        case name
        case arguments
    }

    public init(from decoder: Decoder) throws {
        // Get
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var args = try container.nestedUnkeyedContainer(forKey: .arguments)

        self.name = try container.decode(String.self, forKey: .name)
        self.a = try args.decode(A.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)
        try container.encode(a, forKey: .arguments)
    }
}
