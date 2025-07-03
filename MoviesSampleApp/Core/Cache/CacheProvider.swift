//
//  CacheProvider.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 02/07/25.
//

import Foundation

protocol CacheProviderProtocol {
    typealias Key = Encodable

    func get<T: Codable>(key: Key) async throws -> T
    func set<T: Codable>(key: Key, value: T) async throws
    func delete(key: Key) async throws
}

final class CacheProvider {
    private let storagePath: URL
    private let dateProvider: () -> Date
    private let fileAccessorProvider: (URL) -> FileAccessorProtocol

    init(
        storagePath: URL,
        dateProvider: @escaping @autoclosure () -> Date = Date(),
        fileAccessorProvider: @escaping (URL) -> FileAccessorProtocol = { FileAccessor(fileUrl: $0) }
    ) {
        self.storagePath = storagePath
        self.dateProvider = dateProvider
        self.fileAccessorProvider = fileAccessorProvider
    }

    private func getFileAccessor(forKey key: Key) throws -> FileAccessorProtocol {
        guard let hashedKey = key.cacheKey else {
            throw CacheError.invalidKey
        }
        let url = storagePath.appendingPathComponent(hashedKey)
        return fileAccessorProvider(url)
    }
}

// MARK: - CacheProviderProtocol
extension CacheProvider: CacheProviderProtocol {
    func get<T: Codable>(key: Key) async throws -> T {
        let accessor = try getFileAccessor(forKey: key)
        guard let data = try? await accessor.get() else {
            throw CacheError.notFound(key: key)
        }
        do {
            let decoder = JSONDecoder()
            let timestampedData = try decoder.decode(TimestampedData<T>.self, from: data)
            return timestampedData.data
        } catch {
            throw CacheError.decodingError(description: error.localizedDescription)
        }
    }

    func set<T: Codable>(key: Key, value: T) async throws {
        let accessor = try getFileAccessor(forKey: key)
        do {
            let encoder = JSONEncoder()
            let timestampedObject = TimestampedData(data: value, timestamp: dateProvider())
            let timestampedData = try encoder.encode(timestampedObject)
            try await accessor.set(timestampedData)
        } catch let error as Swift.EncodingError {
            throw CacheError.encodingError(description: error.localizedDescription)
        } catch {
            throw CacheError.unknown(description: error.localizedDescription)
        }
    }

    func delete(key: Key) async throws {
        let accessor = try getFileAccessor(forKey: key)
        do {
            try await accessor.delete()
        } catch {
            throw CacheError.unknown(description: error.localizedDescription)
        }
    }
}

// MARK: - Custom types
private extension CacheProvider {
    struct TimestampedData<T: Codable>: Codable {
        let data: T
        let timestamp: Date
    }
}
