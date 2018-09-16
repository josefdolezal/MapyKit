//
//  FastRPCError.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

enum FastRPCError: Error {
    case serialization(Any, Error?)
}
