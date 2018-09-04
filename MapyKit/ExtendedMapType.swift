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
public enum ExtendedMapType: String {
    case standard = "base-m"
    case tourist = "turist-m"
    case winter = "winter-m"
    case satelite = "bing"
    case geography = "zemepis-m"
    case historical = "army2-m"
    case textMap = "april17-m"
    case in100Years = "april18"

    /// Internal identifier of map type
    var identifier: String { return rawValue }
    /// Rendenring level of map type
    var level: MKOverlayLevel {
        switch self {
    case .standard, .tourist, .winter, .geography, .historical, .textMap, .in100Years: return .aboveLabels
        case .satelite: return .aboveRoads
        }
    }
}
