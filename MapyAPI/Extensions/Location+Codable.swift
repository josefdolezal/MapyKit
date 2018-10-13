//
//  Location+Codable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 28/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

extension Location: Codable {
    // MARK: Structure

    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    // MARK: Decodable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
    }

    // MARK: Encodable

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let geohash = coordinatesGeoHash()

        // Encode coordinates as single value using geohash
        try container.encode(geohash)
    }
}
