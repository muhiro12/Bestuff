//
//  SettingsView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/09.
//

import SwiftUI

enum SettingsTab: Hashable {
    case general
    case debug
}

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var selection: SettingsTab = .general

    var body: some View {
        TabView(selection: $selection.animation()) {
            Tab("General", systemImage: "gear", value: SettingsTab.general) {
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
                }
            }
            Tab("Debug", systemImage: "ladybug", value: SettingsTab.debug) {
                NavigationStack {
                    DebugView()
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    SettingsView()
}
