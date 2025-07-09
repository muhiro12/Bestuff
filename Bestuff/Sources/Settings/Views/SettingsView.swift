//
//  SettingsView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/09.
//

import SwiftUI

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
                Section("Debug") {
                    NavigationLink {
                        DebugView()
                    } label: {
                        Text("Debug")
                    }
                }
            }
            .navigationTitle(Text("Settings"))
        }
    }
}

#Preview(traits: .sampleData) {
    SettingsView()
}
