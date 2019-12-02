//
//  MapyViewController.swift
//  Example
//
//  Created by Josef Dolezal on 04/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import UIKit
import MapKit
import MapyKit
import MapyAPI

class MapyViewController: UIViewController {
    // MARK: Properties

    private static let mapTypes = ExtendedMapType.allCases

    @IBOutlet weak var mapyView: MapyView!
    @IBOutlet weak var tableView: UITableView!
    
    private let service = MapyAPIService()

    private var currentMapType = ExtendedMapType.standard

    // MARK: Controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup table view
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(MapTypeCell.self, forCellReuseIdentifier: MapTypeCell.identifier)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 250)
        ])

        // Setup mapy view
        let mapyView = MapyView(frame: view.frame)
        mapyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapyView.delegate = self
        mapyView.setExtendedMapType(currentMapType)
        mapyView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Annotation")
        self.mapyView = mapyView
        view.insertSubview(mapyView, belowSubview: tableView)

        // Add annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 50.0713667, longitude: 14.4010147)
        mapyView.addAnnotation(annotation)
    }
}

// MARK: - UITableViewDataSource

extension MapyViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MapyViewController.mapTypes.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MapTypeCell.identifier, for: indexPath)
        let mapType = MapyViewController.mapTypes[indexPath.row]

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

extension MapyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mapType = MapyViewController.mapTypes[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)

        // Set new map type to the map view
        self.currentMapType = mapType
        mapyView.setExtendedMapType(mapType)

        // Reload the table view data
        tableView.reloadData()
    }
}

// MARK: - MKMapViewDelegate

extension MapyViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        mapyView.dequeueReusableAnnotationView(withIdentifier: "Annotation", for: annotation)
    }
}
