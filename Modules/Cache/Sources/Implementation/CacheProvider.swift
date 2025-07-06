//
//  CacheProvider.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 02/07/25.
//

import Foundation

public final class CacheProvider {
    private let storagePath: URL
    private let dateProvider: () -> Date
    private let fileAccessorProvider: (URL) -> FileAccessorProtocol

    public init(
        storagePath: URL,
        dateProvider: @escaping @autoclosure () -> Date = Date(),
        fileAccessorProvider: @escaping (URL) -> FileAccessorProtocol = { FileAccessor(fileUrl: $0) }
    ) {
        self.storagePath = storagePath
        self.dateProvider = dateProvider
        self.fileAccessorProvider = fileAccessorProvider
    }
}

// MARK: - CacheProviderProtocol
extension CacheProvider: CacheProviderProtocol {
    public func get<T: Codable>(key: Key) async throws -> T {
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

    public func set<T: Codable>(key: Key, value: T) async throws {
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

    public func delete(key: Key) async throws {
        let accessor = try getFileAccessor(forKey: key)
        do {
            try await accessor.delete()
        } catch {
            throw CacheError.unknown(description: error.localizedDescription)
        }
    }
}

private extension CacheProvider {
    // MARK: - Custom types
    struct TimestampedData<T: Codable>: Codable {
        let data: T
        let timestamp: Date
    }

    // MARK: - Helpers
    func getFileAccessor(forKey key: Key) throws -> FileAccessorProtocol {
        guard let hashedKey = key.cacheKey else {
            throw CacheError.invalidKey
        }
        let url = storagePath.appendingPathComponent(hashedKey)
        return fileAccessorProvider(url)
    }
}
