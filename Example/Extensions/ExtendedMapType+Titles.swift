//
//  ExtendedMapType+Titles.swift
//  Example
//
//  Created by Josef Dolezal on 06/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import MapyKit

extension ExtendedMapType {
    var title: String {
        switch self {
        case .standard: return "Standard"
        case .tourist: return "Tourist"
        case .winter: return "Winter"
        case .satelite: return "Satelite"
        case .hybrid: return "Hybrid"
        case .geography: return "Geography"
        case .historical: return "Historical"
        case .textMap: return "Text map"
        case .in100Years: return "Czech Republic in 100 years"
        }
    }

    static let allTypes: [ExtendedMapType] = [
        .standard,
        .tourist,
        .winter,
        .satelite,
        .hybrid,
        .geography,
        .historical,
        .textMap,
        .in100Years
    ]

    var isMultilayerType: Bool {
        switch self {
        case .hybrid, .textMap, .in100Years: return true
        default: return false
        }
    }
}
