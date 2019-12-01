//
//  Place.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 07/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Describes place found by suggestions/autocomplete API. The only informations available for all
/// suggestions are `location`, `coordinates` and object descriptions. Since address properties may
/// contain various informations (eg. only country and district) so it's not easy to format it in UI,
/// you can use aggregated informations from `shortDesccription` and `longDescription`. These
/// should be used together both contain only partial information.
public struct Place: Decodable {
    private enum CodingKeys: String, CodingKey {
        case wrappedContent = "userData"
        case category
        case latitude
        case longitude
        case boundingBox = "bbox"
        case country
        case region
        case district = "municipality"
        case municipality = "district"
        case area = "quarter"
        case neighbourhood = "ward"
        case zipCode
        case landRegistryNumber = "houseNumber"
        case houseNumber = "streetNumber"
        case shortDescription = "suggestFirstRow"
        case longDescription = "suggestSecondRow"
    }
    // MARK: General informations

    /// The category of place
    public var category: String
    /// GPS coordinates of place
    public var coordinates: Location

    // MARK: Locality

    /// The country (stát) where the place is located (eg. "Česká republika", "Česko", "Slovensko", ...)
    public var country: String?
    /// The region (kraj) where the place is located (eg. "Hlavní město Praha", "Středočeský kraj")
    public var region: String?
    /// The district of the location (eg. "Hlavní město Praha")
    public var district: String?
    /// The municipality (okres) where the place is located (eg. "Praha")
    public var municipality: String?
    /// The area (obec) where the place is located (eg. "Praha 1")
    public var area: String?
    /// The neighbourhood (čtvrť) where the place is located (eg. "Vinohrady")
    public var neighbourhood: String?

    // MARK: Address

    /// The place zip code (směrovací číslo)
    public var zipCode: String?
    /// Land registry number (číslo popisné)
    public var landRegistryNumber: String?
    /// House number (číslo orientační)
    public var houseNumber: String?

    // MARK: Aggregated informations

    /// The short decription describing the place (ex: "Karlův most", "Apartmány Karlův most")
    public var shortDescription: String
    /// The long description refining informations from short description
    /// (ex: "Praha, okres Hlavní město Praha, kraj Hlavní město Praha, Česko",
    /// "Maltézské náměstí 292/10, 118 00  Praha, část obce Malá Strana")
    public var longDescription: String

    public init(from decoder: Decoder) throws {
        let topLevelContainer = try decoder.container(keyedBy: CodingKeys.self)
        let container = try topLevelContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .wrappedContent)

        self.category = try topLevelContainer.decode(String.self, forKey: .category)
        self.coordinates = try Location(
            latitude: container.decode(Double.self, forKey: .latitude),
            longitude: container.decode(Double.self, forKey: .longitude))
        self.country = try container.decodeIfPresent(String.self, forKey: .country)
        self.region = try container.decodeIfPresent(String.self, forKey: .region)
        self.district = try container.decodeIfPresent(String.self, forKey: .district)
        self.municipality = try container.decodeIfPresent(String.self, forKey: .municipality)
        self.area = try container.decodeIfPresent(String.self, forKey: .area)
        self.neighbourhood = try container.decodeIfPresent(String.self, forKey: .neighbourhood)
        self.zipCode = try container.decodeIfPresent(String.self, forKey: .zipCode)
        self.landRegistryNumber = try container.decodeIfPresent(String.self, forKey: .landRegistryNumber)
        self.houseNumber = try container.decode(String.self, forKey: .houseNumber)
        self.shortDescription = try container.decode(String.self, forKey: .shortDescription)
        self.longDescription = try container.decode(String.self, forKey: .longDescription)
    }
}
