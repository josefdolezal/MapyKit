//
//  NavigationPoint+Source.swift
//  MapyAPI
//
//  Created by Josef Dolezal (Admin) on 01/12/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import Foundation

extension NavigationPoint {
    internal enum Source: String, Codable {
        /// Navigation point was picked from using coordinates (no associated poi)
        case coordinates = "coor"
        /// Unknown
        case stre
        case addr
    }
}
