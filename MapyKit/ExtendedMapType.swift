//
//  ExtendedMapType.swift
//  MapyKit
//
//  Created by Josef Dolezal on 04/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation
import MapKit

/// Extended map types for Mapy.cz. Each type may be composed using
/// multiple layers. These layers may be obtained using `layers` property.
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

    // MARK: Public API

    /// List of layers used to render the map. Layers are ordered using
    /// z-index where for each index, lower indexes are rendered before higher indexes.
    var layers: [MapyLayer] {
        switch self {
        case .standard: return [.baseMap]
        case .tourist: return [.touristMap]
        case .winter: return [.winterMap]
        case .satelite: return [.sateliteMap]
        case .hybrid: return [.sateliteMap, .placeLabels]
        case .geography: return [.geographyMap]
        case .historical: return [.hystoricalMap]
        case .textMap: return [.baseMap, .textMap]
        case .in100Years: return [.baseMap, .in100YearsMap]
        }
    }
}
