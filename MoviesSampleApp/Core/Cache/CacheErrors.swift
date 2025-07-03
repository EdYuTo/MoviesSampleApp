//
//  CacheErrors.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 02/07/25.
//

enum CacheError: Error {
    case notFound(key: AnyHashable)
    case decodingError(description: String)
    case encodingError(description: String)
    case unknown(description: String)
    case expired
}
