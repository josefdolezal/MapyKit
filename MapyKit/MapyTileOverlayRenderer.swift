//
//  MapyTileOverlayRenderer.swift
//  MapyKit
//
//  Created by Josef Dolezal on 04/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import MapKit

final class MapyTileRenderer: MKTileOverlayRenderer {
    init(overlay: MapyTileOverlay) {
        overlay.canReplaceMapContent = true

        super.init(overlay: overlay)
    }
}
