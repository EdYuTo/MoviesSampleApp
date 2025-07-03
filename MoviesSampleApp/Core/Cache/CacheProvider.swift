//
//  CacheProvider.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 02/07/25.
//

import Foundation

protocol CacheProviderProtocol {
    func get<T: Codable>(key: AnyHashable) async throws -> T
    func set<T: Codable>(key: AnyHashable, value: T) async throws
    func delete(key: AnyHashable) async throws
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

    private func getFileAccessor(forKey key: AnyHashable) -> FileAccessorProtocol {
        let url = storagePath.appendingPathComponent("MoviesSample\(key.hashValue).store")
        return fileAccessorProvider(url)
    }
}

// MARK: - CacheProviderProtocol
extension CacheProvider: CacheProviderProtocol {
    func get<T: Codable>(key: AnyHashable) async throws -> T {
        let accessor = getFileAccessor(forKey: key)
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

    func set<T: Codable>(key: AnyHashable, value: T) async throws {
        do {
            let accessor = getFileAccessor(forKey: key)
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

    func delete(key: AnyHashable) async throws {
        let accessor = getFileAccessor(forKey: key)
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
