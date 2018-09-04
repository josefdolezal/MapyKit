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
    private let segmentedControl = UISegmentedControl(items: ["Standard", "Satelite", "Tourist"])

    // MARK: Controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let segmentControlWrapper = UIView()
        segmentControlWrapper.backgroundColor = .white

        // Add views to view hierarchy
        view.addSubview(mapyView)
        view.addSubview(segmentControlWrapper)
        segmentControlWrapper.addSubview(segmentedControl)

        mapyView.translatesAutoresizingMaskIntoConstraints = false
        segmentControlWrapper.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        // Layout wrapper to the bottom of the screen
        NSLayoutConstraint.activate([
            segmentControlWrapper.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentControlWrapper.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentControlWrapper.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Layout inside wrapper
        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: segmentControlWrapper.leadingAnchor, constant: 10),
            segmentedControl.trailingAnchor.constraint(equalTo: segmentControlWrapper.trailingAnchor, constant: -10),
            segmentedControl.topAnchor.constraint(equalTo: segmentControlWrapper.topAnchor, constant: 10),
            segmentedControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])

        // Layout view to edges of superview
        NSLayoutConstraint.activate([
            mapyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapyView.topAnchor.constraint(equalTo: view.topAnchor),
            mapyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(handleSegmentedControlValueChange), for: .valueChanged)
    }

    // MARK: UI Bindings

    @objc
    private func handleSegmentedControlValueChange(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            mapyView.setExtendedMapType(.standard)
        } else if sender.selectedSegmentIndex == 1 {
            mapyView.setExtendedMapType(.satelite)
        } else if sender.selectedSegmentIndex == 2 {
            mapyView.setExtendedMapType(.tourist)
        }
    }
}

