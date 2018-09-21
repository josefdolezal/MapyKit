//
//  SerializationBuffer.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 17/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Serialization buffer is public structure which can be only initialized internaly.
/// It's a small wrapper constrainting user of FRPC to use only valid serialization / deserialization.
/// Making the initializer internal does not allow user to create his own (and probably invalid) byte serialization.
public final class SerializationBuffer {
    // MARK: Properties

    /// The actual data representing serialized values. Accessible internaly so it can be composed
    internal let data: Data

    // MARK: Initializers

    /// Creates new serialization wrapper using serialized data. Those
    /// data won't be changed in any way and are sent as-is.
    ///
    /// - Parameter data: Serialized data.
    init(data: Data) {
        self.data = data
    }
}
