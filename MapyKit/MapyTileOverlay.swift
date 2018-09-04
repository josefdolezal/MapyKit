//
//  MapyTileOverlay.swift
//  MapyKit
//
//  Created by Josef Dolezal on 04/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import MapKit

final class MapyOverlay: MKTileOverlay {
    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        return URL(string: "https://mapserver.mapy.cz/winter-m/\(path.z)-\(path.x)-\(path.y)")!
    }
}
