//
//  NetworkResponse.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 17/05/25.
//

public struct NetworkResponse<T> {
    public let statusCode: Int
    public let headers: [AnyHashable: Any]
    public let content: T
}
