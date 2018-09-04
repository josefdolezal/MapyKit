//
//  MapyViewDrawer.swift
//  MapyKit
//
//  Created by Josef Dolezal on 04/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation
import MapKit

final class MapyViewDrawer: NSObject, MKMapViewDelegate {
    /// The delegate to which unhandled MKMapViewDelegate selectors will be forwarded
    weak var secondaryDelegate: MKMapViewDelegate?

    /// Custom map view overlay
    let overlay: MapyTileOverlay
    /// Renderer asociated with custom overlay
    let renderer: MapyTileRenderer

    // MARK: Initialiers

    override init() {
        let overlay = MapyTileOverlay()

        self.overlay = overlay
        self.renderer = MapyTileRenderer(overlay: overlay)
    }

    // MARK: Messaging API

    override func responds(to aSelector: Selector!) -> Bool {
        // Check whether the default implementation responds to selector
        let respondsToASelector = super.responds(to: aSelector)
        // Check if the selector is MapKit related
        let isMapKitSelector = aSelector.isMapKitSelector
        // Check whether the secondary delegate responds to selector
        let selectorImplementedByDelegate = secondaryDelegate?.responds(to: aSelector) ?? false

        // Drawer responds to selector if the method is implemented directly or
        // it's MapKit selector implemented by secondary delegate
        return respondsToASelector || (isMapKitSelector && selectorImplementedByDelegate)
    }

    override func doesNotRecognizeSelector(_ aSelector: Selector!) {
        // If the selector was not recognized, forward it to secondary delegate
        // but only if it's MapKit selector. This may happen if we return `responds(to:)` true
        // so the MKMapView tryes to perform selector on drawer but the method is actually
        // implemented by secondary delegate.
        guard aSelector.isMapKitSelector else {
            super.doesNotRecognizeSelector(aSelector)

            return
        }

        // Forward the selector to secondary delegate
        _ = secondaryDelegate?.perform(aSelector)
    }

    // MARK: MKMapViewDelegate

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Check if the asked renderer should be handled internaly
        guard overlay is MapyTileOverlay else {
            // The renderer should be handled by delegate, check if it's set
            guard let delegate = secondaryDelegate else {
                // Invalid state, crash the app
                assertionFailure("Invalid MapyView state: uknown overlay \(type(of: overlay)) asked to be rendered by MapyKit. Check if your MKMapViewDelegate is correctly set.")
                // Fallback to internal drawer in production code
                return renderer
            }

            // For some reason, this must be force unwrapped
            return delegate.mapView!(mapView, rendererFor: overlay)
        }

        // Return renderer for mapy tiles
        return renderer
    }
}
