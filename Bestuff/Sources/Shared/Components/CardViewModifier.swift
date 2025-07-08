//
//  CardViewModifier.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI

struct CardViewModifier: ViewModifier {
    var background: LinearGradient
    var isTopItem: Bool = false

    func body(content: Content) -> some View {
        content
            .padding()
            .background {
                background
                    .overlay(AppTheme.gradient.opacity(0.3))
                    .overlay(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: DesignMetrics.cornerRadius, style: .continuous))
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignMetrics.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.3))
            )
            .shadow(color: .black.opacity(isTopItem ? 0.3 : DesignMetrics.shadowOpacity),
                    radius: isTopItem ? 14 : DesignMetrics.shadowRadius,
                    x: 0, y: isTopItem ? 7 : 3)
    }
}

extension View {
    func bestCardStyle(using gradient: LinearGradient, isTopItem: Bool = false) -> some View {
        self.modifier(CardViewModifier(background: gradient, isTopItem: isTopItem))
    }
}
