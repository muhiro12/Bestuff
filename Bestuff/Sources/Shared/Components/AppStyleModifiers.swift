//
//  AppStyleModifiers.swift
//  Bestuff
//
//  Created by Codex on 2025/06/04.
//

import SwiftUI

struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                AppTheme.gradient
                    .ignoresSafeArea()
            }
    }
}

struct NavigationStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(AppTheme.gradient, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

extension View {
    func appBackground() -> some View {
        modifier(AppBackgroundModifier())
    }

    func appNavigationStyle() -> some View {
        modifier(NavigationStyleModifier())
    }
}
