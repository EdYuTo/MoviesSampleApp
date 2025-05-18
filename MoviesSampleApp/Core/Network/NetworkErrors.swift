//
//  NetworkErrors.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 17/05/25.
//

enum NetworkError: Error {
    case connectionError
    case decodingError(description: String, statusCode: Int)
    case invalidParams
    case invalidResponse
    case invalidUrl
}

enum ConnectionError: Int {
    case timeout = -1001
    case cannotConnectToHost = -1004
    case connectionLost = -1005
    case unreachable = -1009
}
