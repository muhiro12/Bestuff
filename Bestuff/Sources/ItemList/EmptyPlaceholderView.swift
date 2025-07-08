//
//  EmptyPlaceholderView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI

struct EmptyPlaceholderView: View {
    var body: some View {
        Section {
            VStack(alignment: .center, spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)
                Text("Start tracking your favorites!")
                    .font(AppFont.title)
                Text("Tap the + button to add your first Best Item.")
                    .font(AppFont.body)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
    }
}
