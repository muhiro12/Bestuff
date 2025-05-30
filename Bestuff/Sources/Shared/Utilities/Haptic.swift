//
//  Haptic.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI

@MainActor
enum Haptic {
    static func impact() {
        if UserDefaults.standard.bool(forKey: "hapticsEnabled") {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
}
