//
//  FastRPCService.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 18/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

typealias Procedure = String

enum HTTPMethod: String {
    case post

    var type: String { return rawValue.uppercased() }
}

final class FastRPCService {
    // MARK: Properties

    private let url: URL
    private let session: URLSession

    // MARK: Initializers

    init(url: URL, sessionConfiguration: URLSessionConfiguration = .default) {
        self.url = url
        self.session = URLSession(configuration: sessionConfiguration)
    }

    // MARK: Public API

    func call(procedure: Procedure, parameters: [FastRPCSerializable], procedureSuccess: @escaping (Data) -> Void, procedureFailure: @escaping (FastRPCError) -> Void) {
        do {
            let request = try procedureRequest(for: procedure, parameters: parameters)
            let task = session.dataTask(with: request) { data, _, error in
                guard let data = data else {
                    procedureFailure(.unknown(error))

                    return
                }

                if let error = error {
                    procedureFailure(.unknown(error))
                    return
                }

                procedureSuccess(data)
            }

            task.resume()
        } catch {
            let frpcError = error as? FastRPCError ?? .unknown(error)

            procedureFailure(frpcError)
        }
    }

    // MARK: Private API

    private func procedureRequest(for procedure: Procedure, parameters: [FastRPCSerializable]) throws -> URLRequest {
        var request = URLRequest(url: url)
        let serializedParameters = try serialize(procedureParameters: parameters)

        request.httpMethod = HTTPMethod.post.type
        request.httpBody = serializedParameters

        return request
    }

    private func serialize(procedureParameters parameters: [FastRPCSerializable]) throws -> Data {
        return try parameters.reduce(Data()) { partial, element in
            var data = partial

            data.append(try element.serialize())

            return data
        }
    }
}
