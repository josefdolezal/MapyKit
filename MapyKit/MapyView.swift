//
//  MapyView.swift
//  MapyKit
//
//  Created by Josef Dolezal on 04/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import MapKit

public final class MapyView: MKMapView {
    // MARK: Properties

    public override var delegate: MKMapViewDelegate? {
        get { return drawer.secondaryDelegate }
        set {
            // Add new delegate to drawer
            drawer.secondaryDelegate = newValue
            // Notify MapView about delegate changes
            super.delegate = drawer
        }
    }

    /// Drawer taking care of rendering custom map overlay
    private let drawer: MapyViewDrawer

    // MARK: Initializers

    override public init(frame: CGRect) {
        self.drawer = MapyViewDrawer(mapType: .standard)

        super.init(frame: frame)

        setupDrawer()
    }

    required public init?(coder aDecoder: NSCoder) {
        self.drawer = MapyViewDrawer(mapType: .standard)

        super.init(coder: aDecoder)

        setupDrawer()
    }

    // MARK: Public API

    public func setExtendedMapType(_ mapType: ExtendedMapType) {
        drawer.set(mapType: mapType)
    }

    // MARK: Private API

    private func setupDrawer() {
        drawer.mapView = self
        super.delegate = drawer
    }
}
