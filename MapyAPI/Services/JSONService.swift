//
//  JSONService.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 07/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

public enum JSONAPIError: Error {
    case network(Error, URLResponse?)
    case responseDecoding(Error, URLResponse?)
}

/// Remote API service treating response data as JSON objects.
final class JSONService {
    // MARK: Properties

    /// Base requests URL
    private let baseURL: URL
    /// Session used for making requests
    private let session: URLSession
    /// Decoder for json objects
    private let decoder: JSONDecoder

    // MARK: Initializers

    init(baseURL: URL, session: URLSession = URLSession.shared) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = JSONDecoder()
    }

    // MARK: Public API

    func request<T: Decodable>(_ type: T.Type, path: String, parameters: [String: String] = [:], success: @escaping (T) -> Void, failure: @escaping (JSONAPIError) -> Void) -> URLSessionTask? {
        let request = JSONService.buildRequest(url: baseURL, path: path, parameters: parameters)

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            // Check for network error
            guard error == nil else {
                failure(.network(error!, response))
                return
            }

            // When no error occured, the response must be presented
            assert(response != nil)
            assert(data != nil)

            // Sanitize response data
            let json = data ?? Data()

            // Try to decode response data
            do {
                let object = try self.decoder.decode(type, from: json)

                // Success callback for decoded data
                success(object)
            } catch {
                // Failure callback for decoding error
                failure(.responseDecoding(error, response))
            }
        }

        // Run request and return the task
        task.resume()

        return task
    }

    // MARK: Private API

    private static func buildRequest(url: URL, path: String, parameters: [String: String]) -> URLRequest {
        // Add query parameters using URLComponents
        let baseURL: URL

        // If the URL is not malformed, get and update it's components
        if var components = URLComponents(url: url.appendingPathComponent(path), resolvingAgainstBaseURL: false) {
            // Store old items (if any)
            let oldItems = components.queryItems ?? []
            // Create new query items from given parameters
            let items = oldItems + parameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }

            // Update URL componets
            components.queryItems = items
            baseURL = components.url ?? url
        } else {
            assertionFailure("Components should be always available for all base urls.")
            baseURL = url
        }

        // Create request builder
        var request = URLRequest(url: baseURL)

        // Configure request defaults
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"

        return request
    }
}
