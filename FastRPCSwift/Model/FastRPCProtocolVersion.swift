//
//  FastRPCProtocolVersion.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 23/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Currently used FastRPC version standard.
public enum FastRPCProtocolVersion: Int {
    case version1 = 1
    case version2 = 2
    case version3 = 3

    /// FRPC major version
    var major: Int { return self.rawValue }
    /// FRPC minor version
    var minor: Int { return 0 }
    /// FRPC version string
    var versionString: String { return "\(major).\(minor)"}
}
