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
public struct Place {
    // MARK: General informations

    /// The category of place
    public var category: String
    /// GPS coordinates of place
    public var coordinates: Location

    // MARK:

    /// The country (stát) where the place is located (ex: "Česká republika", "Česko", "Slovensko", ...)
    public var country: String?
    /// The region (kraj) where the place is located (ex: "Hlavní město Praha", "Středočeský kraj")
    public var region: String?
    /// The municipality (obec) where the place is located (ex: "Praha")
    public var municipality: String?
    /// The municipal district (městská část) where the place is located (ex: "Praha 1")
    public var municipalDistrict: String?
    /// The district (čtvrť) where the place is located (ex: "Vinohrady")
    public var district: String?

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
}
