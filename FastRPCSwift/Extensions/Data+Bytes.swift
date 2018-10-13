//
//  Data+Bytes.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 21/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

internal extension Data {
    static func + (_ lhs: Data, _ rhs: Data) -> Data {
        var result = lhs

        result.append(rhs)

        return result
    }
}
