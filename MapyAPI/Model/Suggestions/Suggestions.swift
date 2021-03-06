//
//  Suggestions.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 07/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Wraps list of suggested places for given query. Used as temporary solution
/// due to limitations of `Decodable` collections which are not on top level.
/// The structure is interal and only it's content is exposed publicly.
struct Suggestions: Decodable {
    /// Custom coding keys
    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case places = "result"
    }

    /// Suggestions request identifier
    var identifier: String
    /// List of suggested places
    var places: [Place]
}
