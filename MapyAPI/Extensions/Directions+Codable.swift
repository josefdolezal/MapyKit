//
//  Directions+Codable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 15/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

extension Directions: Codable {
    // MARK: Structure

    private enum ContainerCodingKeys: String, CodingKey {
        case altitude
    }

    private enum CodingKeys: String, CodingKey {
        case coordinatesGeohash = "geometryCode"
        case distances = "lengths"
        case elevationLoss
        case elevationGain
        case altitudes = "altitude"
        case time = "totalTime"
    }

    // MARK: Decodable

    init(from decoder: Decoder) throws {
        // Get wrapping container
        let outerContainer = try decoder.container(keyedBy: ContainerCodingKeys.self)
        // Get nested container containing actual data
        let container = try outerContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .altitude)

        // Decode the values from nested container
        self.coordinatesGeohash = try container.decode(String.self, forKey: .coordinatesGeohash)
        self.distances = try container.decode([Double].self, forKey: .distances)
        self.elevationLoss = try container.decode(Int.self, forKey: .elevationLoss)
        self.elevationGain = try container.decode(Int.self, forKey: .elevationGain)
        self.altitudes = try container.decode([Int].self, forKey: .altitudes)
        self.time = try container.decode(Int.self, forKey: .time)
    }

    // MARK: Encodable

    func encode(to encoder: Encoder) throws {
        // Get wrapping container
        var outerContainer = encoder.container(keyedBy: ContainerCodingKeys.self)
        // Get nested container for encoding data
        var container = outerContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .altitude)

        // Encode the data into nested container
        try container.encode(coordinatesGeohash, forKey: .coordinatesGeohash)
        try container.encode(distances, forKey: .distances)
        try container.encode(elevationLoss, forKey: .elevationLoss)
        try container.encode(elevationGain, forKey: .elevationGain)
        try container.encode(altitudes, forKey: .altitudes)
        try container.encode(time, forKey: .time)
    }
}
