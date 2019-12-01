//
//  EmbeddedItinerary.swift
//  MapyAPI
//
//  Created by Josef Dolezal (Admin) on 01/12/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import Foundation

public struct EmbeddedItinerary: Encodable {
    private enum CodingKeys: String, CodingKey {
        case isItineraryIncluded = "itinerary"
    }

    var isItineraryIncluded: Bool
}
