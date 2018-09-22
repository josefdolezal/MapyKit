//
//  Location.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 22/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import FastRPCSwift

/// Location representing GPS coordinates.
public struct Location {
    // MARK: Properties

    /// GPS coordinates latitude
    public var latitude: Double
    /// GPS coordinates longitude
    public var longitude: Double

    // MARK: Initializer

    /// Creates new GPS coordinates.
    ///
    /// - Parameters:
    ///   - latitude: Coordinates latitude
    ///   - longitude: Coordinates longitude
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
