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

        // Decode place
        try self.init(
            category: category,
            coordinates: outerContainer.decode(Location.self, forKey: .data),
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
