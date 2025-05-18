//
//  AuthInterceptor.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 17/05/25.
//

import Foundation

// To enable git tracking of this file, please run the following command:
// git update-index --no-assume-unchanged MoviesSampleApp/Core/Network/AuthInterceptor.swift
// Remember to always run git update-index --assume-unchanged MoviesSampleApp/Core/Network/AuthInterceptor.swift
// to avoid pushing you api key to the repository.
final class AuthInterceptor: URLProtocol {
    // swiftlint:disable:next line_length superfluous_disable_command
    private static let accessToken = "{API_ACCESS_TOKEN}"
    private var sessionTask: URLSessionTask?

    override static func canInit(with request: URLRequest) -> Bool {
        true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        var newRequest = request
        newRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        newRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        return newRequest
    }

    override func startLoading() {
        sessionTask = AuthorizedURLSession.defaultSession.dataTask(
            with: request
        ) { [weak self] (data, response, error) in
            guard let self else { return }

            if let error {
                client?.urlProtocol(self, didFailWithError: error)
                return
            }

            guard let response else {
                client?.urlProtocol(self, didFailWithError: NetworkError.invalidResponse)
                return
            }

            if let data {
                client?.urlProtocol(self, didLoad: data)
            }

            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
            client?.urlProtocolDidFinishLoading(self)
        }

        sessionTask?.resume()
    }

    override func stopLoading() {
        sessionTask?.cancel()
        sessionTask = nil
    }
}

final class AuthorizedURLSession {
    static var defaultSession = URLSession.shared
    static var shared: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [AuthInterceptor.self]
        return URLSession(configuration: configuration)
    }
}
