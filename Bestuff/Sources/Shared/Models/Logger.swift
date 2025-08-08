//
//  Logger.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/10.
//

import Foundation
@_exported import OSLog

extension Logger {
    init(_ file: String) {
        self.init(
            subsystem: Bundle.main.bundleIdentifier!,
            category: file
        )
    }
}
