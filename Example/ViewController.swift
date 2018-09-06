//
//  ViewController.swift
//  Example
//
//  Created by Josef Dolezal on 04/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import UIKit
import MapKit
import MapyKit

class ViewController: UIViewController {
    // MARK: Properties

    private static let mapTypes = ExtendedMapType.allTypes

    private let mapyView = MapyView()
    private let tableView = UITableView()

    private var currentMapType = ExtendedMapType.standard

    // MARK: Controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add views to view hierarchy
        view.addSubview(mapyView)
        view.addSubview(tableView)

        mapyView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        // Layout view to edges of superview
        NSLayoutConstraint.activate([
            mapyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapyView.topAnchor.constraint(equalTo: view.topAnchor),
        ])

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: mapyView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3)
        ])

        // Setup table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(MapTypeCell.self, forCellReuseIdentifier: MapTypeCell.identifier)

        // Setup mapy view
        mapyView.setExtendedMapType(currentMapType)
        mapyView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Annotation")

        // Add annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 50.0713667, longitude: 14.4010147)
        mapyView.addAnnotation(annotation)
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewController.mapTypes.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MapTypeCell.identifier, for: indexPath)
        let mapType = ViewController.mapTypes[indexPath.row]

        cell.textLabel?.text = mapType.title
        cell.detailTextLabel?.text = mapType.isMultilayerType
            ? "Multi-layer map type"
            : "Single-layer map type"
        cell.accessoryType = mapType == currentMapType
            ? .checkmark
            : .none

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mapType = ViewController.mapTypes[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)

        // Set new map type to the map view
        self.currentMapType = mapType
        mapyView.setExtendedMapType(mapType)

        // Reload the table view data
        tableView.reloadData()
    }
}

// MARK: - MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return mapyView.dequeueReusableAnnotationView(withIdentifier: "Annotation", for: annotation)
    }
}
