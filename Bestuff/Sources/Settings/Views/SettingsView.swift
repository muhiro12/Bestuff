//
//  SettingsView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/09.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("General") {
                    Label("Version 1.0.0", systemImage: "number")
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

#Preview {
    SettingsView()
}
