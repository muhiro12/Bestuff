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
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: DesignMetrics.cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(isTopItem ? 0.1 : DesignMetrics.shadowOpacity),
                    radius: isTopItem ? 10 : DesignMetrics.shadowRadius,
                    x: 0, y: isTopItem ? 4 : 2)
    }
}

extension View {
    func bestCardStyle(using gradient: LinearGradient, isTopItem: Bool = false) -> some View {
        self.modifier(CardViewModifier(background: gradient, isTopItem: isTopItem))
    }
}
