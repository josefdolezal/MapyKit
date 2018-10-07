//
//  Location.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 24/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import FastRPCSwift

/// Represents GPS location coordinations.
public struct Location: Codable {
    // MARK: Properties

    /// Coordinations latitude
    public var latitude: Double
    /// Coordinations longitude
    public var longitude: Double

    // MARK: Initializers

    /// Creates new coordinates with given latitude and longitude.
    ///
    /// - Parameters:
    ///   - latitude: Coordinates latitude
    ///   - longitude: Coordinates longitude
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
