//
//  CacheProviderProtocol.swift
//  Cache
//
//  Created by Edson Yudi Toma on 06/07/25.
//

import Foundation

public protocol CacheProviderProtocol {
    typealias Key = Encodable

    func get<T: Codable>(key: Key) async throws -> T
    func set<T: Codable>(key: Key, value: T) async throws
    func delete(key: Key) async throws
}
