//
//  NetworkRequest.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 17/05/25.
//

import Foundation

public struct NetworkRequest {
    public var endpoint: String
    public var body: Data?
    public var httpMethod: HTTPMethod
    public var queryParams: [String: String]?
    public var headers: [String: String]?
    public var decoder: JSONDecoder

    public init(
        endpoint: String,
        body: Data? = nil,
        httpMethod: HTTPMethod = .get,
        queryParams: [String : String]? = nil,
        headers: [String : String]? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.endpoint = endpoint
        self.body = body
        self.httpMethod = httpMethod
        self.queryParams = queryParams
        self.headers = headers
        self.decoder = decoder
    }
}
