//
//  FastRPCVersion.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 23/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Currently used FastRPC version standard.
public enum FastRPCVersion {
    /// FRPC major version
    public static let major: Int = 2
    /// FRPC minor version
    public static let minor: Int = 1
    /// FRPC version string
    public static var versionString: String { return "\(major).\(minor)"}
}
