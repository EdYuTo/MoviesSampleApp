//
//  DebugLoggerProtocol.swift
//  DebugLogger
//
//  Created by Edson Yudi Toma on 06/07/25.
//

public protocol DebugLoggerProtocol {
    func logInfo(_ message: String, args: CVarArg...)
    func logError(_ message: String, args: CVarArg...)
    func logWarning(_ message: String, args: CVarArg...)
}
