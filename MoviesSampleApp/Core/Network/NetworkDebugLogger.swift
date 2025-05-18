//
//  NetworkDebugLogger.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

#if DEBUG
import Foundation

final class NetworkDebugLogger: URLProtocol {
    override static func canInit(with request: URLRequest) -> Bool {
        debugPrint("[Request] Headers:", request.allHTTPHeaderFields)
        debugPrint("[Request] method:", request.httpMethod)
        debugPrint("[Request] url:", request.url?.absoluteString)
        return false
    }
}
#endif
