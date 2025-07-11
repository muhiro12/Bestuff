//
//  SettingsListView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/09.
//

import SwiftUI

struct SettingsListView: View {
    var body: some View {
        List {
            Section("General") {
                Label("Version 1.0.0", systemImage: "number")
            }
            Section("Support") {
                Link(
                    destination: URL(string: "mailto:support@example.com")!
                ) {
                    Label("Contact Support", systemImage: "envelope")
                }
                Link(
                    destination: URL(string: "https://example.com")!
                ) {
                    Label("Visit Website", systemImage: "safari")
                }
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CloseButton()
            }
        }
    }
}

#Preview(traits: .sampleData) {
    SettingsListView()
}
