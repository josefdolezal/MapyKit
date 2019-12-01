//
//  File.swift
//  MapyAPI
//
//  Created by Josef Dolezal (Admin) on 30/11/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import Foundation

internal struct TollExludedCountries: Codable {
    private enum CodingKeys: String, CodingKey {
        case countries = "tollExcludeCountries"
    }

    var countries: [String]

    static let `default` = TollExludedCountries(countries: [])

    private init(countries: [String]) {
        self.countries = countries
    }
}
