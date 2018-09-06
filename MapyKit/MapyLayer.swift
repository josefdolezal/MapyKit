//
//  MapyLayer.swift
//  MapyKit
//
//  Created by Josef Dolezal on 06/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

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

    var identifier: String {
        return rawValue
    }

    var isSolidLayer: Bool {
        return self != .placeLabels
    }
}
