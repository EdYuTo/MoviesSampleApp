//
//  NetworkProviderProtocol.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 17/05/25.
//

import Foundation

public protocol NetworkProviderProtocol {
    func makeRequest<T: Decodable>(_ request: NetworkRequest) async throws -> NetworkResponse<T>
    func makeRequest(_ request: NetworkRequest) async throws -> NetworkResponse<Data>
}
