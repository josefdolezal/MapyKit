//
//  SerializationBuffer.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 17/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

public final class SerializationBuffer {
    // MARK: Properties

    private var data: Data

    // MARK: Initializers

    init() {
        self.data = Data()
    }

    // MARK: Public API

    public func container() -> SerializationContainer {
        return SerializationContainer(buffer: self)
    }

    // MARK: Internal API

    func add(members: [Data]) {
        
    }
}
