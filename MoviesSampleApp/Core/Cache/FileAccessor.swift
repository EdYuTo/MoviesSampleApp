//
//  FileAccessor.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 02/07/25.
//

import Foundation

protocol FileAccessorProtocol {
    func get() async throws -> Data
    func set(_ data: Data) async throws
    func delete() async throws
}

actor FileAccessor {
    private let fileUrl: URL

    init(fileUrl: URL) {
        self.fileUrl = fileUrl
    }
}

// MARK: - FileAccessorProtocol
extension FileAccessor: FileAccessorProtocol {
    func get() async throws -> Data {
        try Data(contentsOf: fileUrl)
    }

    func set(_ data: Data) async throws {
        try data.write(to: fileUrl)
    }

    func delete() async throws {
        try FileManager.default.removeItem(at: fileUrl)
    }
}
