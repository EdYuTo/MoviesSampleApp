//
//  DebugLogger.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 06/07/25.
//

import os

protocol DebugLoggerProtocol {
    func logInfo(_ message: String, args: CVarArg...)
    func logError(_ message: String, args: CVarArg...)
    func logWarning(_ message: String, args: CVarArg...)
}

final class DebugLogger {
    private let subsystem: String
    private let category: String
    private lazy var logSystem = OSLog(subsystem: subsystem, category: category)

    init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
    }

    static func debug(_ object: Any) {
        let debugger = DebugLogger(subsystem: "MoviesSampleApp", category: "Search")
        debugger.logInfo("%@", args: String(describing: object))
    }
}

// MARK: - DebugLoggerProtocol
extension DebugLogger: DebugLoggerProtocol {
    func logInfo(_ message: String, args: CVarArg...) {
        let message = String(format: message, args)
        log(type: .info, message: message)
    }

    func logError(_ message: String, args: CVarArg...) {
        let message = String(format: message, args)
        log(type: .fault, message: message)
    }

    func logWarning(_ message: String, args: CVarArg...) {
        let message = String(format: message, args)
        log(type: .error, message: message)
    }
}

// MARK: - Helpers
private extension DebugLogger {
    func log(type: OSLogType, message: String) {
        #if DEBUG
        os_log(type, log: logSystem, "%@", message)
        #endif
    }
}
