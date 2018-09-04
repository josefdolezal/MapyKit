//
//  ExtendedMapType.swift
//  MapyKit
//
//  Created by Josef Dolezal on 04/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation
import MapKit

/// Extended map types for Mapy.cz
///
/// - standard: Standard map
/// - tourist: Map with hiking trails
/// - winter: Map of winter resorts
/// - satelite: Satelite map with street labels
/// - geography: Geography map
/// - historical: Historical map (Czech Republic only)
/// - textMap: Text only map (April fools day easter egg, 2017)
/// - in100Years: Czech Republic in 100 years (April fools day easter egg, 2018)
public enum ExtendedMapType {
    case standard
    case tourist
    case winter
    case satelite
    case hybrid
    case geography
    case historical
    case textMap
    case in100Years

    /// Internal identifier of map type
    var identifier: String {
        switch self {
        case .standard: return "base-m"
        case .tourist: return "turist-m"
        case .winter: return "winter-m"
        case .satelite, .hybrid: return "bing"
        case .geography: return "zemepis-m"
        case .historical: return "army2-m"
        case .textMap: return "april17-m"
        case .in100Years: return "april18"
        }
    }
    /// Rendenring level of map type
    var level: MKOverlayLevel {
        switch self {
    case .standard, .tourist, .winter, .satelite, .geography, .historical, .textMap, .in100Years: return .aboveLabels
        case .hybrid: return .aboveRoads
        }
    }
}
