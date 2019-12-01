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

    public typealias Completion<Response> = (Result<Response, Error>) -> Void

    // MARK: Properties

    /// FRPC method endpoint URL.
    private let url: URL
    /// HTTP session.
    private let session: URLSession
    private let encoder: FastRPCEncoder
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
        self.encoder = FastRPCEncoder()
        self.decoder = FastRPCDecoder()
    }

    // MARK: Public API

    @discardableResult
    public func call<Response: Decodable>(path: String, procedure: String, version: FastRPCProtocolVersion = .version2, completion: @escaping (Result<Response, Error>) -> Void) throws -> Disposable {
        let request = try prepare(path: path, rpc: encoder.encode(procedure: procedure, version: version))

        return execute(request: request, completion: completion)
    }

    @discardableResult
    public func call<Response: Decodable, Arg1: Encodable>(
        path: String,
        procedure: String,
        arg: Arg1,
        version: FastRPCProtocolVersion = .version2,
        completion: @escaping (Result<Response, Error>) -> Void
    ) -> Disposable? {
        do {
            let request = try prepare(path: path, rpc: encoder.encode(procedure: procedure, arg, version: version))
            return execute(request: request, completion: completion)
        } catch {
            completion(.failure(error))
            return nil
        }
    }

    @discardableResult
    public func call<Response: Decodable, Arg1: Encodable, Arg2: Encodable>(
        path: String,
        procedure: String,
        arg1: Arg1,
        arg2: Arg2,
        version: FastRPCProtocolVersion = .version2,
        completion: @escaping (Result<Response, Error>) -> Void
    ) -> Disposable? {
        do {
            let request = try prepare(path: path, rpc: encoder.encode(procedure: procedure, arg1, arg2, version: version))
            return execute(request: request, completion: completion)
        } catch {
            completion(.failure(error))
            return nil
        }
    }

    @discardableResult
    public func call<Response: Decodable, Arg1: Encodable, Arg2: Encodable, Arg3: Encodable>(
        path: String,
        procedure: String,
        arg1: Arg1,
        arg2: Arg2,
        arg3: Arg3,
        version: FastRPCProtocolVersion = .version2,
        completion: @escaping (Result<Response, Error>) -> Void
    ) -> Disposable? {
        do {
            let request = try prepare(path: path, rpc: encoder.encode(procedure: procedure, arg1, arg2, version: version))
            return execute(request: request, completion: completion)
        } catch {
            completion(.failure(error))
            return nil
        }
    }

    private func prepare(path: String, rpc: Data) -> URLRequest {
        var request = URLRequest(url: url.appendingPathComponent(path))
        // Encode data using base64
        let body = rpc.base64EncodedData()

        // Configure request
        request.httpMethod = HTTPMethod.post.type
        request.addHeader(.contentType(.base64frpc))
        request.addHeader(.accept(.base64frpc))
        request.httpBody = body

        return request
    }

    private func execute<Response: Decodable>(request: URLRequest, completion: @escaping Completion<Response>) -> Disposable {
        let decoder = self.decoder

        let task = session.dataTask(with: request) { data, response, error in
            // Decode base64 encoded data (ignore invalid characters such as '\n' and so on)
            let base64Encoded = data.flatMap({ Data(base64Encoded: $0, options: .ignoreUnknownCharacters) })

            if let data = base64Encoded {
                do {
                    print(data.map { "\($0)" }.joined(separator: " "))
                    let response = try decoder.decodeResponse(Response.self, from: data)

                    completion(.success(response))
                } catch {
                    do {
                        let error = try decoder.decodeFault(from: data)
                        completion(.failure(NSError(domain: "decoding", code: error.code, userInfo: ["message": error.message])))
                    } catch {
                        completion(.failure(error))
                    }
                }
            } else if let error = error {
                completion(.failure(error))
            } else {
                assertionFailure("Unknown case.")
            }
        }

        task.resume()

        return Disposable(task: task)
    }
}

public class Disposable {
    private var task: URLSessionTask

    public init(task: URLSessionTask) {
        self.task = task
    }

    public func dispose() {
        task.cancel()
    }
}
