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
    // MARK: Properties

    /// The delegate to which unhandled MKMapViewDelegate selectors will be forwarded.
    weak var secondaryDelegate: MKMapViewDelegate?
    /// Map view where the overlay should be drawn.
    weak var mapView: MKMapView? {
        // Once the map view is set, setup overlays
        didSet { set(mapType: mapType) }
    }

    /// Custom map overlays
    private var overlays: [MapyTileOverlay]
    /// Current type of map.
    private var mapType: ExtendedMapType

    // MARK: Initialiers

    init(mapType: ExtendedMapType) {
        self.mapType = mapType
        self.overlays = MapyViewDrawer.createCustomOverlays(for: mapType)
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

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        // Forward unhandled MapKit selectors to secondary delegate
        guard aSelector.isMapKitSelector else {
            return super.forwardingTarget(for: aSelector)
        }

        return secondaryDelegate
    }

    // MARK: Public API

    /// Sets new map type for map view. During type exchange, all old overlays
    /// handled by drawer are discarded and new ones are set instead.
    ///
    /// - Parameter mapType: New overlay type for map view.
    func set(mapType: ExtendedMapType) {
        // Keep the reference old overlays so it can be removed later
        let oldOverlays = self.overlays
        // Create new overlays for given type
        self.overlays = MapyViewDrawer.createCustomOverlays(for: mapType)

        // Remove all old layers and add new
        oldOverlays.forEach { self.mapView?.remove($0) }
        // We will insert layers one by one at index 0,
        // reverse the collection so the order of overlays stays the same
        // after insertion
        overlays.reversed()
            // Insert each layer to the lowest level,
            // so all custom layers inserted by user are rendered above map
            .forEach { mapView?.insert($0, at: 0, level: .aboveLabels) }

        self.mapType = mapType
    }

    // MARK: MKMapViewDelegate

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Check whether the requested overlay is internal
        let isInternalOverlay = overlays.contains { $0 === overlay }

        // Check if the given overlay should be handled internaly
        guard isInternalOverlay else {
            // The renderer should be handled by delegate, check if it's set
            guard let delegate = secondaryDelegate else {
                // Invalid state, crash the app
                assertionFailure("MapyKit: Invalid MapyView state: uknown overlay \(type(of: overlay)) asked to be rendered by MapyKit. Check if your MKMapViewDelegate is correctly set.")

                // Fallback to default renderer
                return MKOverlayRenderer(overlay: overlay)
            }

            // For some reason, this must be force unwrapped
            return delegate.mapView!(mapView, rendererFor: overlay)
        }

        // Create new renderer for given overlay
        return MKTileOverlayRenderer(overlay: overlay)
    }

    // MARK: Private API

    /// Helper factory for mapping map type into drawable layers.
    ///
    /// - Parameter mapType: Type for which the layers will be created.
    /// - Returns: Map overlays for given map type.
    private static func createCustomOverlays(for mapType: ExtendedMapType) -> [MapyTileOverlay] {
        // For each layer of given type, ceate map overlay and renderer.
        return mapType.layers.map(MapyTileOverlay.init)
    }
}
