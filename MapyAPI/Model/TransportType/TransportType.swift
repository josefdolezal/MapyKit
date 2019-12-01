//
//  TransportType.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 22/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation
import FastRPCSwift

/// Transport type used for navigation purpose. Some transport types require additional
/// informations to make navigation roads more reliable.
///
/// - car: Navigation for car
/// - bike: Navigation for bike
/// - foot: Foot navigation
/// - skiing: Cross country skiing navigation
/// - boat: Canoeing navigation
public enum TransportType: Codable {
    internal enum CodingKeys: String, CodingKey {
        case value = "criterion"
    }
    // MARK: Structure

    case car(PreferredAttributes)
    case bike(BikeType)
    case foot(TourType)
    case skiing
    case boat

    /// Remote API transport type identifier
    var identifier: Int {
        switch self {
        case .car(.fast): return 111
        case .car(.short): return 113
        case .bike(.mountain): return 121
        case .bike(.road): return 122
        case .foot(.short): return 131
        case .foot(.touristic): return 132
        case .skiing: return 141
        case .boat: return 143
        }
    }

    // MARK: Decodable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawValue = try container.decode(Int.self, forKey: .value)

        switch rawValue {
        case 111: self = .car(.fast)
        case 113: self = .car(.short)
        case 121: self = .bike(.mountain)
        case 122: self = .bike(.road)
        case 131: self = .foot(.short)
        case 132: self = .foot(.touristic)
        case 141: self = .skiing
        case 143: self = .boat
        default:
            throw DecodingError.typeMismatch(TransportType.self, DecodingError.Context.init(codingPath: [], debugDescription: "Unsupported raw value \(rawValue)."))
        }
    }

    // MARK: Encodable

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(identifier, forKey: .value)
    }
}
