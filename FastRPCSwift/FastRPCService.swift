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
    // MARK: Structure

    public typealias FailureCallback = (FastRPCError) -> Void

    // MARK: Properties

    /// FRPC method endpoint URL.
    private let url: URL
    /// HTTP session.
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: FastRPCDecoder

    // MARK: Initializers

    /// Creates new FRPC service. The methods will be called against given URL.
    ///
    /// - Parameters:
    ///   - url: Methods call endpoint
    ///   - sessionConfiguration: URL session configuration
    public init(url: URL, sessionConfiguration: URLSessionConfiguration = .default) {
        self.url = url
        self.session = URLSession(configuration: sessionConfiguration)
        self.encoder = JSONEncoder()
        self.decoder = FastRPCDecoder()
    }

    // MARK: Public API

    @discardableResult
    public func call<Response: Decodable>(path: String, procedure: Procedure0, success: @escaping (Response) -> Void, failure: @escaping FailureCallback) -> URLSessionTask? {
        return frpcCall(path: path, procedure: procedure, success: success, failure: failure)
    }

    @discardableResult
    public func call<Response: Decodable, A: Encodable>(path: String, procedure: Procedure1<A>, success: @escaping (Response) -> Void, failure: @escaping FailureCallback) -> URLSessionTask? {
        return frpcCall(path: path, procedure: procedure, success: success, failure: failure)
    }

    // MARK: Private API

    private func frpcCall<Procedure: Encodable, Response: Decodable>(path: String, procedure: Procedure, success: @escaping (Response) -> Void, failure: @escaping FailureCallback) -> URLSessionTask? {
        do {
            // Compose the final rpc call URL
            let url = self.url.appendingPathComponent(path)
            // Configure request, serialize procedure call
            let request = try prepare(url: url, procedure: procedure, response: Response.self)
            // Request configuration is ready, make the actual HTTP call
            return self.request(request, success: success, failure: failure)
        } catch {
            guard let frpcerror = error as? FastRPCDecodingError else {
                failure(.unknown(error))

                return nil
            }

            failure(.requestEncoding(procedure, frpcerror))
        }

        return nil
    }

    private func prepare<P: Encodable, R: Decodable>(url: URL, procedure: P, response: R.Type) throws -> URLRequest {
        // Create mutable request and serialize procedure
        var request = URLRequest(url: url)
        let rpc = try encoder.encode(procedure)
        // Encode data using base64
        let body = rpc.base64EncodedData()

        // Configure request
        request.httpMethod = HTTPMethod.post.type
        request.addHeader(.contentType(.base64frpc))
        request.addHeader(.accept(.base64frpc))
        request.httpBody = body

        return request
    }

    private func request<T: Decodable>(_ request: URLRequest, success: @escaping (T) -> Void, failure: @escaping FailureCallback) -> URLSessionTask? {
        // Keep strong reference to decoder inside task callback
        let decoder = self.decoder
        // Create request task
        let task = session.dataTask(with: request) { data, _, error in
            // If there was an error, introspect it and finish the call
            guard error == nil else {
                failure(.unknown(error))

                return
            }

            // No error occured, the data must be set
            guard let data = data else {
                // Undefined behavior: The request didn't fail but there is no response
                failure(.unknown(error))

                return
            }

            // We have a response, decode it
            do {
                // Decode the data as remote procedure response with return type of `T`
                let response = try decoder.decode(Response<T>.self, from: data)

                // Finish the request with response value
                success(response.body)
            } catch {
                // Oops, the response has an invalid format, report it
                failure(.responseDecoding(data, error))

                return
            }
        }

        // Run the URL request
        task.resume()

        // The task is created successfully, pass it to the caller
        return task
    }
}
