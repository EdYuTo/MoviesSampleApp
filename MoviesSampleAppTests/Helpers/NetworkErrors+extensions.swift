//
//  NetworkErrors+extensions.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import Foundation
@testable
import MoviesSampleApp

extension NetworkError {
    init?(error: NSError) {
        guard error.domain == "MoviesSampleApp.NetworkError" else { return nil }
        switch error.code {
        case 0:
            self = .connectionError
        case 1:
            self = .decodingError(description: String(), statusCode: -1)
        case 2:
            self = .invalidParams
        case 3:
            self = .invalidResponse
        case 4:
            self = .invalidUrl
        default:
            return nil
        }
    }
}
