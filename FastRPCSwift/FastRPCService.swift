//
//  FastRPCService.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 18/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

/// FastRPC API service. Takes care of HTTP communication and data serialization / deserialization.
public final class FastRPCService {
    // MARK: Properties

    /// FRPC method endpoint URL.
    private let url: URL
    /// HTTP session.
    private let session: URLSession

    // MARK: Initializers

    /// Creates new FRPC service. The methods will be called against given URL.
    ///
    /// - Parameters:
    ///   - url: Methods call endpoint
    ///   - sessionConfiguration: URL session configuration
    public init(url: URL, sessionConfiguration: URLSessionConfiguration = .default) {
        self.url = url
        self.session = URLSession(configuration: sessionConfiguration)
    }

    // MARK: Public API

    /// Calls remote procedure on base URL. The procedure associated type is used
    /// as method response serialization hint. Based on procedure call result uses
    /// either `success` or `failure` callback. Failure callback is called either synchronously
    /// (the call failed before making async HTTP request) or asynchronously on failure during
    /// HTTP request.
    ///
    /// - Parameters:
    ///   - procedure: The procedure to be called on remote URL
    ///   - success: Callback called on procedure call success
    ///   - failure: Callback called on procedure call failure
    public func call<Response: FastRPCSerializable>(procedure: Procedure<Response>, success: @escaping (Data) -> Void, failure: @escaping (FastRPCError) -> Void) -> URLSessionTask? {
        do {
            let request = try procedureRequest(for: procedure)
            let task = session.dataTask(with: request) { data, _, error in
                guard let data = data else {
                    failure(.unknown(error))

                    return
                }

                if let error = error {
                    failure(.unknown(error))
                    return
                }

                success(data)
            }

            // Run the URL request
            task.resume()

            return task
        } catch {
            let frpcError = error as? FastRPCError ?? .unknown(error)

            failure(frpcError)

            // We are not able to construct request task, return nil
            return nil
        }
    }

    // MARK: Private API

    /// Helper function for creating procedure call HTTP requset. Takes care
    /// data serialization and common request configuration.
    ///
    /// - Parameter procedure: The procedure associated with request
    /// - Returns: New request for given remote procedure call
    /// - Throws: FastRPCError on procedure serialization error
    private func procedureRequest<Response: FastRPCSerializable>(for procedure: Procedure<Response>) throws -> URLRequest {
        // Create mutable request and serialize procedure
        var request = URLRequest(url: url)
        let rpc = try procedure.serialize()
        // Encode data using base64
        let body = rpc.data.base64EncodedData()

        // Configure request
        request.httpMethod = HTTPMethod.post.type
        request.addHeader(.contentType(.base64frpc))
        request.addHeader(.accept(.base64frpc))
        request.httpBody = body

        return request
    }
}
