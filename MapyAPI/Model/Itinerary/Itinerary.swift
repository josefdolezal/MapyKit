//
//  Itinerary.swift
//  MapyAPI
//
//  Created by Josef Dolezal (Admin) on 01/12/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import Foundation

public struct Itinerary: Decodable {
    private enum CodingKeys: String, CodingKey {
        case altitude
        case routes
        case routeContent = "data"
    }

    public var altitude: Altitude
    public var routes: [Route]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var routesContainer = try container.nestedUnkeyedContainer(forKey: .routes)
        var routes: [Route] = []

        while !routesContainer.isAtEnd {
            let container = try routesContainer.nestedContainer(keyedBy: CodingKeys.self)
            var routeContainer = try container.nestedUnkeyedContainer(forKey: .routes)

            while !routeContainer.isAtEnd {
                let container = try routeContainer.nestedContainer(keyedBy: CodingKeys.self)
                try routes.append(container.decode(Route.self, forKey: .routeContent))
            }
        }

        self.altitude = try container.decode(Altitude.self, forKey: .altitude)
        self.routes = routes
    }
}

public struct Route: Decodable {
    private enum CodingKeys: String, CodingKey {
        case length
        case time
        case points = "routePoint"
    }

    public var length: Double
    public var time: Double
    public var points: [Point]
}

public struct Point: Decodable {
    public enum Turn: String, Decodable {
        case straight = "TurnStraight"

        case turnLeft = "TurnLeft"
        case turnSharpLeft = "TurnSharpLeft"

        case turnRight = "TurnRight"
        case turnSharpRight = "TurnSharpRight"

        case destination = "Destination"
    }

    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case text = "commandText"
        case turn = "commandType"
    }

    public var name: String
    public var text: String
    public var turn: Turn
}

public struct Altitude: Decodable {
    private enum CodingKeys: String, CodingKey {
        case altitude
        case elevationGain
        case elevationLoss
        case coordinates = "geometryCode"
        case lengths
    }

    public var altitude: [Double]
    public var elevationGain: Double
    public var elevationLoss: Double
    public var coordinates: [Location]
    public var lengths: [Double]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let geometry = try container.decode(String.self, forKey: .coordinates)

        self.altitude = try container.decode([Double].self, forKey: .altitude)
        self.elevationGain = try container.decode(Double.self, forKey: .elevationGain)
        self.elevationLoss = try container.decode(Double.self, forKey: .elevationLoss)
        self.coordinates = LocationCoder.locations(from: geometry)
        self.lengths = try container.decode([Double].self, forKey: .lengths)
    }
}
