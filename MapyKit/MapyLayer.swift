//
//  MapyLayer.swift
//  MapyKit
//
//  Created by Josef Dolezal on 06/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Map layer represents single rendered map layer. The layer may be solid which means
/// that the layer is opaque and doesn't need other layer below self.
///
/// - baseMap: Standard map layer. Solid.
/// - touristMap: Layer with highlighted hiking trails. Solid.
/// - winterMap: Layer of winter resorts. Solid.
/// - sateliteMap: Layer with aerial photos. Solid.
/// - geographyMap: Geography map layer. Solid.
/// - hystoricalMap: Historical map layer. Solid.
/// - textMap: Textual representation layer.
/// - in100Years: Futuristic map layer.
/// - placeLabels: Layer with highlighted places.
enum MapyLayer: String {
    case baseMap = "base-m"
    case touristMap = "turist-m"
    case winterMap = "winter-m"
    case sateliteMap = "bing"
    case geographyMap = "zemepis-m"
    case hystoricalMap = "army2-m"
    case textMap = "april17-m"
    case in100YearsMap = "april18"
    case placeLabels = "hybrid-sparse-m"

    /// Map layer remote identifier.
    var identifier: String {
        return rawValue
    }

    /// Indicates whether the layer is solid. Solid layers
    /// are opaque and doesn't need aditional sublayers.
    var isSolidLayer: Bool {
        return self != .placeLabels
    }
}
