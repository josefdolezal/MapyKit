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
        self.drawer = MapyViewDrawer()

        super.init(frame: frame)

        setupMapyDrawer()
    }

    required public init?(coder aDecoder: NSCoder) {
        self.drawer = MapyViewDrawer()

        super.init(coder: aDecoder)

        setupMapyDrawer()
    }

    // MARK: Private API

    private func setupMapyDrawer() {
        super.delegate = drawer
        add(drawer.overlay, level: .aboveLabels)
    }
}
