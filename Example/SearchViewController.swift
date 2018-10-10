//
//  SearchViewController.swift
//  Example
//
//  Created by Josef Dolezal on 09/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import UIKit
import MapyAPI

final class SearchViewController: UITableViewController, UISearchBarDelegate {
    private let mapyService = MapyAPIService()
    private var places = [Place]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var searchRequestWorkItem: DispatchWorkItem?

    // MARK: UITableViewDatasource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        let place = places[indexPath.row]

        cell.textLabel?.text = place.shortDescription
        cell.detailTextLabel?.text = place.longDescription

        return cell
    }

    // MARK: UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // If the phrase is empty, remove search results
        guard !searchText.isEmpty else {
            searchRequestWorkItem?.cancel()
            places = []

            return
        }

        // Since this method is called for every key stroke, we want to debounce the requests.
        // We schedule API request with small delay, if phrase is not updated during the delay, we run the request.
        // If the phrase is updated, the we cancel the request for previous phrase and schedule new one.
        debounceSearchRequest(for: searchText)
    }

    // MARK: Private API

    private func debounceSearchRequest(for phrase: String) {
        // If we scheduled request for previous item, cancel it before scheduling next one
        searchRequestWorkItem?.cancel()

        // Create work item which will make search request for given phrase
        let item = DispatchWorkItem { [weak self] in
            // Check if the screen still exists
            guard let self = self else { return }

            // Run the request with two callbacks, update places on success, print error on failure
            self.mapyService.suggestions(forPhrase: phrase, count: 10,
                success: { places in
                    // Deliver the result on main thread
                    DispatchQueue.main.async { [weak self] in
                        self?.places = places
                    }
                }, failure: { [weak self] error in
                    self?.showError(error)
                })
        }

        // Schedule the work item and create strong reference
        searchRequestWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: item)
    }

    private func showError(_ error: Error) {
        let title = "Something went wrong.."
        let okAction = UIAlertAction(title: "Ok :-(", style: .default, handler: { _ in })
        let controller = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)

        controller.addAction(okAction)

        present(controller, animated: true)
    }
}
