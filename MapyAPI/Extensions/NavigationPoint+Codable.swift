//
//  NavigationPoint+Codable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 28/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import FastRPCSwift

//extension NavigationPoint: Codable {
//    // MARK: Structure
//
//    fileprivate enum DescriptionCodingKeys: String, CodingKey {
//        case fetchPhoto
//        case ratio = "ratios"
//        case lang
//    }
//
//    // MARK: Decodable
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
//        self.coordinates = try container.decode(Location.self, forKey: .coordinates)
//        self.transportType = try container.decodeIfPresent(TransportType.self, forKey: .transportType)
//    }
//
//    // MARK: Encodable
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        try container.encode(id, forKey: .id)
//        // Currently, we only support coordinates as navigatiom points, so it's OK to hardcode it
//        try container.encode("coor", forKey: .source)
//        try container.encode(coordinates, forKey: .coordinates)
//
//        // Serialize transport only if it's available
//        if let transportType = transportType {
//            var transportContainer = encoder.container(keyedBy: CodingKeys.self)
//
//            try transportContainer.encode(transportType.identifier, forKey: .transportCriterio)
//        }
//
//        // Since we don't use description parameters, add dummy empty object
//        var descriptionContainer = encoder.container(keyedBy: DescriptionCodingKeys.self)
//
//        try descriptionContainer.encode(true, forKey: .fetchPhoto)
//        try descriptionContainer.encode(["3x2"], forKey: .ratio)
//        try descriptionContainer.encode(["en"], forKey: .lang)
//    }
//}
