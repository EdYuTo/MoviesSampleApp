//
//  NetworkRequest.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 17/05/25.
//

import Foundation

struct NetworkRequest {
    var endpoint: String
    var body: Data?
    var httpMethod: HTTPMethod = .get
    var queryParams: [String: String]?
    var headers: [String: String]?
    var decoder: JSONDecoder = JSONDecoder()
}
