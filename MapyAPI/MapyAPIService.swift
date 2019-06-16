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

    public typealias Callback<T> = (T) -> Void

    public typealias SuccessDataCallback = Callback<Data>
    public typealias SuccessPlacesCallback = Callback<[Place]>

    public typealias FRPCFailureCallback = Callback<FastRPCError>
    public typealias JSONFailureCallback = Callback<JSONAPIError>

    // MARK: Properties

    /// Internal service handling FRPC communication
    private let frpcService: FastRPCService
    /// Internal service handling JSON API communication
    private let jsonService: JSONService

    // MARK: Initializers

    /// Creates new API service.
    public init() {
        let frpcBaseURL = URL(string: "https://pro.mapy.cz")!
        let jsonBaseURL = URL(string: "https://api.mapy.cz")!

        self.frpcService = FastRPCService(url: frpcBaseURL)
        self.jsonService = JSONService(baseURL: jsonBaseURL)
    }

    // MARK: Public API

    /// Requests navigation data for given series of points with given commute type.
    ///
    /// - Parameters:
    ///   - success: Request success callback
    ///   - failure: Request failure callback
    @discardableResult
    public func navigate(from: NavigationPoint, to: NavigationPoint, through: [NavigationPoint] = [], success: @escaping (Int) -> Void, failure: @escaping FRPCFailureCallback) -> URLSessionTask? {
        // Create procedure from given parameters
        fatalError()
//        let procedure = MapyAPIService.createNavigationProcedure(from: from, to: to, through: through)

//        return frpcService.call(path: "tplanner", procedure: procedure, success: success, failure: failure)
    }

    @discardableResult
    public func suggestions(forPhrase phrase: String, count: Int, success: @escaping ([Place]) -> Void, failure: @escaping JSONFailureCallback) -> URLSessionTask? {
        // Create request parameters
        let parameters = [
            "count": "\(count)",
            "phrase": phrase,
            "enableCategories": "1"
        ]

        // Unwrap returned value using custom success callback
        let callback: (Suggestions) -> Void = { suggestions in success(suggestions.places) }

        // Run the request
        return jsonService.request(Suggestions.self, path: "suggest/", parameters: parameters, success: callback, failure: failure)
    }

    // MARK: Private API

//    private static func createNavigationProcedure(from: NavigationPoint, to: NavigationPoint, through: [NavigationPoint]) -> Procedure1<[NavigationPoint]> {
//        // Merge serialiable points
//        let locations = [from] + through + [to]
//        // Create the procedure call representation
//        fatalError()
//    }
}
