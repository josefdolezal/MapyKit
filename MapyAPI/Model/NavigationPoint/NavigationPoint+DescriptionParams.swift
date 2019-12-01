//
//  NavigationPoint+DescriptionParams.swift
//  MapyAPI
//
//  Created by Josef Dolezal (Admin) on 01/12/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import Foundation

extension NavigationPoint {
    /// Fake nested object used for FRPC serialization (syntax sugar for nested objects is not ready yet)
    internal struct DescriptionParams: Codable {
        private enum CodingKeys: String, CodingKey {
            case fetchPhoto
            case ratios
            case languages = "lang"
        }

        var fetchPhoto: Bool
        var ratios: [String]
        var languages: [String]

        private init(fetchPhoto: Bool, ratios: [String], languages: [String]) {
            self.fetchPhoto = fetchPhoto
            self.ratios = ratios
            self.languages = languages
        }

        static let `default` = DescriptionParams(fetchPhoto: true, ratios: ["3x2"], languages: ["en"])
    }
}
