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

    // MARK: UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {


        mapyService.suggestions(forPhrase: searchText, count: 10,
success: { places in

        }, failure: { error in

        })
    }
}
