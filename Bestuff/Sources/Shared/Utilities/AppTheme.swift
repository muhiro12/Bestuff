//
//  AppTheme.swift
//  Bestuff
//
//  Created by Codex on 2025/06/04.
//

import SwiftUI

enum AppTheme {
    static let gradient = LinearGradient(
        colors: [
            Color.accentColor.opacity(0.8),
            Color.purple.opacity(0.6),
            Color.blue.opacity(0.6)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
