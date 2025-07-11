//
//  SettingsView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/09.
//

import SwiftUI
import SwiftUtilities

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        NavigationStack {
            List {
                Section("General") {
                    Label("Version 1.0.0", systemImage: "number")
                    Toggle("Dark Mode", isOn: $isDarkMode)
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
            .navigationTitle(Text("Settings"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButton()
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    SettingsView()
}
