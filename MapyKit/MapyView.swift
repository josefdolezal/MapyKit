//
//  MapyView.swift
//  MapyKit
//
//  Created by Josef Dolezal on 04/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import MapKit

/// The actual mapy.cz map view. Renders map type based in current configuration
/// using native `MapKit` technology. Default map type is `.standard`.
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

    /// Sets current map type to new value.
    ///
    /// - Parameter mapType: New map type.
    public func setExtendedMapType(_ mapType: ExtendedMapType) {
        drawer.set(mapType: mapType)
    }

    // MARK: Private API

    /// Sets up internal map view drawer.
    private func setupDrawer() {
        drawer.mapView = self
        // Here be sure to setup the delegate for super class, otherwise
        // the drawer will become it's own secondaty delegate.
        super.delegate = drawer
    }
}
