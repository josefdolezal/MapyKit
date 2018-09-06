//
//  MapyViewDrawer.swift
//  MapyKit
//
//  Created by Josef Dolezal on 04/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation
import MapKit

/// Drawer takes care for complete map rendering flow. The `MKMapView` API
/// for drawing custom overlays is handled using delegate pattern. Since we
/// want to the `MapyKit` user to be able to set the delegate himself,
/// we use delegate forwarding for unrecognized `MapKit` selectors
/// and overlays set up by user.
final class MapyViewDrawer: NSObject, MKMapViewDelegate {
    // MARK: Structure

    private typealias DrawableLayer = (overlay: MapyTileOverlay, renderer: MKTileOverlayRenderer)

    // MARK: Properties

    /// The delegate to which unhandled MKMapViewDelegate selectors will be forwarded.
    weak var secondaryDelegate: MKMapViewDelegate?
    /// Map view where the overlay should be drawn.
    weak var mapView: MKMapView? {
        // Once the map view is set, setup overlays
        didSet { set(mapType: mapType) }
    }

    /// Layer to be drawn on map view.
    private var drawableLayers: [DrawableLayer]
    /// Current type of map.
    private var mapType: ExtendedMapType

    // MARK: Initialiers

    init(mapType: ExtendedMapType) {
        self.mapType = mapType
        self.drawableLayers = MapyViewDrawer.createOverlayRenderer(for: mapType)
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

    // MARK: Public API

    /// Sets new map type for map view. During type exchange, all old overlays
    /// handled by drawer are discarded and new ones are set instead.
    ///
    /// - Parameter mapType: New overlay type for map view.
    func set(mapType: ExtendedMapType) {
        // Keep the reference for old layers so it can be removed later
        let oldLayers = self.drawableLayers
        // Create new layers for given type
        self.drawableLayers = MapyViewDrawer.createOverlayRenderer(for: mapType)

        // Remove all old layers and add new
        oldLayers.forEach { self.mapView?.remove($0.overlay) }
        drawableLayers.forEach { self.mapView?.add($0.overlay, level: .aboveLabels) }

        self.mapType = mapType
    }

    // MARK: MKMapViewDelegate

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Check if the asked renderer should be handled internaly
        guard overlay is MapyTileOverlay else {
            // The renderer should be handled by delegate, check if it's set
            guard let delegate = secondaryDelegate else {
                // Invalid state, crash the app
                assertionFailure("MapyKit: Invalid MapyView state: uknown overlay \(type(of: overlay)) asked to be rendered by MapyKit. Check if your MKMapViewDelegate is correctly set.")

                // Try to fallback to internal drawer in production code, fatal inconsistency otherwise
                if let renderer = drawableLayers.first?.renderer {
                    return renderer
                }

                fatalError("MapyKit: Fatal internal inconsistency. No renderer available for given overlay \(type(of: overlay)).")
            }

            // For some reason, this must be force unwrapped
            return delegate.mapView!(mapView, rendererFor: overlay)
        }

        // Try to find layer for given overlay
        let maybeLayer = drawableLayers
            .filter { $0.overlay === overlay }
            .first

        // Check if layer was found. Fatal internal inconsistency otherwise, crash the app.
        guard let layer = maybeLayer else {
            fatalError("MapyKit: Fatal internal inconsistency. No renderer available for internal overlay type.")
        }

        // Return renderer for mapy tiles
        return layer.renderer
    }

    // MARK: Private API

    /// Helper factory for mapping map type into drawable layers.
    ///
    /// - Parameter mapType: Type for which the layers will be created.
    /// - Returns: New array of drawable layers.
    private static func createOverlayRenderer(for mapType: ExtendedMapType) -> [DrawableLayer] {
        // For each layer of given type, ceate map overlay and renderer.
        return mapType.layers.map { layer in
            let overlay = MapyTileOverlay(layer: layer)
            let renderer = MKTileOverlayRenderer(overlay: overlay)

            return (overlay, renderer)
        }
    }
}
