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

    /// The type of map to be rendered. Default: `.standard`.
    var mapType: ExtendedMapType = .standard

    // MARK: Overlay lifecycle

    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        return URL(string: "https://mapserver.mapy.cz/\(mapType.identifier)/\(path.z)-\(path.x)-\(path.y)")!
    }
}
