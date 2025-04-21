//
//  SettingsView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("dynamicAppIcon") private var dynamicAppIcon = false
    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [BestItem]
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @State private var showingResetAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Theme")) {
                    Toggle("Auto Dark Mode", isOn: $isDarkMode)
                        .onChange(of: isDarkMode) { _, _ in
                            if let windowScene = UIApplication.shared.connectedScenes
                                .compactMap({ $0 as? UIWindowScene }).first {
                                for window in windowScene.windows {
                                    window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
                                }
                            }
                        }
                    Toggle("Auto Switch App Icon", isOn: $dynamicAppIcon)
                        .onChange(of: dynamicAppIcon) { _, newValue in
                            let iconName = newValue
                            ? (UITraitCollection.current.userInterfaceStyle == .dark ? "AppIconDark" : "AppIconLight")
                            : nil
                            UIApplication.shared.setAlternateIconName(iconName)
                        }
                    Text("Override system dark mode preference")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Section {
                    Label("Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown")", systemImage: "number")
                }
                // TODO: Replace this placeholder with actual subscription functionality
                Section(header: Text("Subscription")) {
                    Label("Rate us on the App Store", systemImage: "star")
                }
                // TODO: Replace this placeholder with actual license list view
                Section(header: Text("Licenses")) {
                    Label("Open Source Licenses", systemImage: "doc.plaintext")
                }
                // TODO: Replace this placeholder with actual notification settings
                Section(header: Text("Notifications")) {
                    Label("Manage Notifications", systemImage: "bell.badge")
                        .foregroundColor(.gray)
                        .opacity(0.5)
                        .disabled(true)
                }
                Section {
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                    }
                }
                .alert("Reset All Data", isPresented: $showingResetAlert) {
                    Button("Delete All", role: .destructive) {
                        for item in allItems {
                            modelContext.delete(item)
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This will permanently delete all your items.")
                }
                Section(header: Text("Categories")) {
                    NavigationLink(destination: CategoryManagerView()) {
                        Label("Manage Categories", systemImage: "folder")
                    }
                }
                Section(header: Text("Tags")) {
                    NavigationLink(destination: TagManagerView()) {
                        Label("Manage Tags", systemImage: "tag")
                    }
                }
                Section(header: Text("Preferences")) {
                    Toggle("Enable Haptics", isOn: $hapticsEnabled)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
