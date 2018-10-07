//
//  Place+Codable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 07/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

extension Place: Decodable {
    /// Used for keyed outer container, contains place informations under inner keyed container.
    private enum OuterCodingKeys: String, CodingKey {
        case data = "userData"
        case category
    }

    /// Used for inner container which contains place informations.
    private enum InnerCodingKeys: String, CodingKey {
        case latitude
        case longitude

        case country
        case region = "district"
        case municipality
        case municipalDistrict = "quarter"
        case district = "ward"

        case zipCode
        case landRegistryNumber = "houseNumber"
        case houseNumber = "streetNumber"

        case shortDescription = "suggestFirstRow"
        case longDescription = "suggestSecondRow"
    }

    public init(from decoder: Decoder) throws {
        // Create keyed wrapper container
        let outerContainer = try decoder.container(keyedBy: OuterCodingKeys.self)
        let innerContainer = try outerContainer.nestedContainer(keyedBy: InnerCodingKeys.self, forKey: .data)

        // Get category from outer container
        let category = try outerContainer.decode(String.self, forKey: .category)

        // Structurize coordinates from flat representation
        let coordinates = try Location(
            latitude: innerContainer.decode(Double.self, forKey: .latitude),
            longitude: innerContainer.decode(Double.self, forKey: .longitude)
        )

        // Decode place
        try self.init(
            category: category,
            coordinates: coordinates,
            country: innerContainer.decodeNonEmpty(String.self, forKey: .country),
            region: innerContainer.decodeNonEmpty(String.self, forKey: .region),
            municipality: innerContainer.decodeNonEmpty(String.self, forKey: .municipality),
            municipalDistrict: innerContainer.decodeNonEmpty(String.self, forKey: .municipalDistrict),
            district: innerContainer.decodeNonEmpty(String.self, forKey: .district),
            zipCode: innerContainer.decodeNonEmpty(String.self, forKey: .zipCode),
            landRegistryNumber: innerContainer.decodeNonEmpty(String.self, forKey: .landRegistryNumber),
            houseNumber: innerContainer.decodeNonEmpty(String.self, forKey: .houseNumber),
            shortDescription: innerContainer.decode(String.self, forKey: .shortDescription),
            longDescription: innerContainer.decode(String.self, forKey: .longDescription)
        )
    }
}

/// Custom encoding for array of places, which is not located on toplevel but under key in object.
public extension Array where Element == Place {
    /// Wraps key for structured array of places.
    private enum CodingKeys: String, CodingKey {
        case result
    }

    init(from decoder: Decoder) throws {
        // Get unkeyed container from outer object
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .result)
        let count = 0

        // Create storage for elements decoding
        var places = [Place]()

        // Decode elements one-by-one
        while unkeyedContainer.currentIndex < count {
            try places.append(unkeyedContainer.decode(Place.self))
        }

        // Initialize self from decoded places storage
        self = places
    }
}

extension KeyedDecodingContainer {
    func decodeNonEmpty(_ type: String.Type, forKey key: Key) throws -> String? {
        let value = try decode(String.self, forKey: key)

        return value.isEmpty
            ? nil
            : value
    }
}
