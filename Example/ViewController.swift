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

    private let mapyView = MapyView()
    private let segmentedControl = UISegmentedControl()

    // MARK: Controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add mapy view to view hierarchy
        view.addSubview(mapyView)
        mapyView.translatesAutoresizingMaskIntoConstraints = false

        // Layout view to edges of superview
        NSLayoutConstraint.activate([
            mapyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapyView.topAnchor.constraint(equalTo: view.topAnchor),
            mapyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

