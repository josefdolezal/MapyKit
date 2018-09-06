//
//  MapyTileOverlay.swift
//  MapyKit
//
//  Created by Josef Dolezal on 04/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import MapKit

final class MapyTileOverlay: MKTileOverlay {
    // MARK: Properties

    /// The map layer drawn using this overlay.
    let layer: MapyLayer

    // MARK: Initializers

    init(layer: MapyLayer) {
        self.layer = layer

        super.init(urlTemplate: nil)

        self.canReplaceMapContent = layer.isSolidLayer
    }

    // MARK: Overlay lifecycle

    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        return URL(string: "https://mapserver.mapy.cz/\(layer.identifier)/\(path.z)-\(path.x)-\(path.y)")!
    }
}
