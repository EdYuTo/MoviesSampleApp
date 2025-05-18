//
//  NetworkResponse.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 17/05/25.
//

struct NetworkResponse<T> {
    let statusCode: Int
    let headers: [AnyHashable: Any]
    let content: T
}
