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

    public typealias Completion<T> = (Result<T, Error>) -> Void

    // MARK: Properties

    /// Internal service handling FRPC communication
    private let frpcService: FastRPCService
    /// Internal service handling JSON API communication
    private let jsonService: JSONService

    // MARK: Initializers

    /// Creates new API service.
    public init() {
        let frpcBaseURL = URL(string: "https://pro.mapy.cz")!
        let jsonBaseURL = URL(string: "https://pro.mapy.cz")!

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
    public func navigate(from: NavigationPoint, to: NavigationPoint, through: [NavigationPoint] = [], completion: @escaping Completion<String>) -> Disposable? {
        let locations = [from] + through + [to]

        return frpcService.call(path: "tplanner", procedure: "simpleRoute", arg1: locations, arg2: TollExludedCountries.default, version: .version2_1, completion: completion)
    }

    @discardableResult
    public func suggestions(forPhrase phrase: String, count: Int, completion: @escaping Completion<[Place]>) -> Disposable {
        // Create request parameters
        let parameters = [
            "count": "\(count)",
            "phrase": phrase,
            "enableCategories": "1"
        ]

        // Unwrap returned value using custom success callback
        let callback: (Result<Suggestions, Error>) -> Void = { suggestions in
            completion(suggestions.map { $0.places })
        }

        // Run the request
        return jsonService.request(Suggestions.self, path: "suggest/", parameters: parameters, completion: callback)
    }
}
