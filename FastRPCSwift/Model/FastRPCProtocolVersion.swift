//
//  FastRPCProtocolVersion.swift
//  FastRPCSwift
//
//  Created by Josef Dolezal on 23/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// Currently used FastRPC version standard.
public enum FastRPCProtocolVersion {
    case version1
    case version2
    case version2_1
    case version3

    /// FRPC major version
    public var major: Int { return version.major }
    /// FRPC minor version
    public var minor: Int { return version.minor }
    /// FRPC version string
    public var versionString: String { return "\(major).\(minor)"}

    public init?(major: Int, minor: Int) {
        switch (major, minor) {
        case (1, 0): self = .version1
        case (2, 0): self = .version2
        case (2, 1): self = .version2_1
        case (3, 0): self = .version3
        default: return nil
        }
    }

    private var version: (major: Int, minor: Int) {
        switch self {
        case .version1: return (1, 0)
        case .version2: return (2, 0)
        case .version2_1: return (2, 1)
        case .version3: return (3, 0)
        }
    }
}
