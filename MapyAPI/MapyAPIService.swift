//
//  MapyAPIService.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 22/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import FastRPCSwift

/// API service handling communication with Mapy.cz.
public final class MapyAPIService {
    // MARK: Structure

    public typealias SuccessCallback = (Data) -> Void
    public typealias FailureCallback = (FastRPCError) -> Void

    // MARK: Properties

    /// Base API url
    private let baseURL: URL
    /// Internal service handling FRPC communication
    private let frpcService: FastRPCService

    // MARK: Initializers

    /// Creates new API service.
    public init() {
        self.baseURL = URL(string: "https://pro.mapy.cz/")!
        self.frpcService = FastRPCService(url: baseURL)
    }

    // MARK: Public API

    /// Requests navigation data for given series of points with given commute type.
    ///
    /// - Parameters:
    ///   - success: Request success callback
    ///   - failure: Request failure callback
    public func navigate(from: Location, to: Location, through: [Location] = [], type: TransportType, success: @escaping SuccessCallback, failure: @escaping FailureCallback) {
        // Create procedure from given parameters
        let procedure = MapyAPIService.createNavigationProcedure(from: from, to: to, through: through, type: type)

        // Call remote procedure
        frpcService.call(procedure: procedure, success: success, failure: failure)
    }

    // MARK: Private API

    private static func createNavigationProcedure(from: Location, to: Location, through: [Location], type: TransportType) -> Procedure<Int> {
        // Map locations into serializable parameters
        let locations = ([from] + through + [to])
            .flatMap { [$0.latitude, $0.longitude] }

        // Combine all procedure parameters
        let parameters: [FastRPCSerializable] = locations + [type]
        let procedure: Procedure<Int> = Procedure(name: "navigate", parameters: parameters)

        return procedure
    }
}
