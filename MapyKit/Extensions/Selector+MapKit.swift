//
//  Selector+MapKit.swift
//  MapyKit
//
//  Created by Josef Dolezal on 04/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

extension Selector {
    /// Indicates whether the selector is used inside `MapKit` framework.
    var isMapKitSelector: Bool {
        return description.hasPrefix("mapView:")
    }
}
