//
//  Logger.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/10.
//

import Foundation
@_exported import OSLog

extension Logger {
    nonisolated(unsafe) init(_ file: String) {
        self.init(
            subsystem: ProcessInfo.processInfo.processName,
            category: file
        )
    }
}
