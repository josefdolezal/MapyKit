//
//  SerializationContainer.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 17/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

public final class SerializationContainer {
    // MARK: Properties

    private var members: [Data]
    private weak var buffer: SerializationBuffer?

    // MARK: Initializers

    init(buffer: SerializationBuffer) {
        self.members = []
        self.buffer = buffer
    }

    // MARK: Primitives

    public func serialize(bool: Bool, for key: String) {

    }

    public func serialize(int: Int, for key: String) {

    }

    public func serialize(string: String, for key: String) {

    }

    // MARK: Objects

    // MARK: Collections

    public func serialize(collection: [Bool], for key: String) {

    }

    public func serialize(collection: [Int], for key: String) {

    }

    public func serialize(collection: String, for key: String) {

    }

    deinit {
        buffer?.add(members: members)
    }
}
