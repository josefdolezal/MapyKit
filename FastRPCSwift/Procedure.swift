//
//  Procedure.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 21/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Represents remote procedure. Is called with serialized `parameters`, the generic parameter
/// `Output` is used for call return type.
public struct Procedure<Output: FastRPCSerializable>: FastRPCSerializable {
    // MARK: Properties

    /// The procedure name
    public var name: String
    /// Procedure parameters
    public var parameters: [FastRPCSerializable]

    // MARK: Initializers

    /// Creates new remote procedure representation. Procedure may be called using `FastRPCService`.
    ///
    /// - Parameters:
    ///   - name: Name of remote procedure
    ///   - parameters: Remote procedure parameters
    public init(name: String, parameters: [FastRPCSerializable]) {
        self.name = name
        self.parameters = parameters
    }

    // MARK: FastRPCSerializable

    public func serialize() throws -> SerializationBuffer {
        /// Encode procedure name using .utf8
        guard let nameData = name.data(using: .utf8) else {
            throw FastRPCError.serialization(name, nil)
        }

        // Serialize procedure parameters
        let parametersData = try parameters
            .map { try $0.serialize().data }
            .reduce(Data(), +)

        // Combine procedure data (id, name length and parameters)
        var data = FastRPCObejectType.procedure.identifier.usedBytes
        data.append(nameData.count.truncatedBytes(to: 1))
        data.append(nameData)
        data.append(parametersData)

        return SerializationBuffer(data: data)
    }
}
