//
//  DebugListView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/09.
//

import SwiftData
import SwiftUI

struct DebugListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isCreateAlertPresented = false
    @State private var isClearAlertPresented = false

    var body: some View {
        List {
            Section("Information") {
                HStack {
                    Text("App Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("OS Version")
                    Spacer()
                    Text(ProcessInfo.processInfo.operatingSystemVersionString)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Language")
                    Spacer()
                    Text(Locale.current.language.languageCode?.identifier ?? Locale.current.identifier)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Region")
                    Spacer()
                    Text(Locale.current.region?.identifier ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Time Zone")
                    Spacer()
                    Text(TimeZone.current.identifier)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Calendar")
                    Spacer()
                    Text(Calendar.current.identifier.debugDescription)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Stored Items")
                    Spacer()
                    Text("\(stuffCount)")
                        .foregroundStyle(.secondary)
                }
            }
            Section("Actions") {
                Button("Create Sample Data", systemImage: "doc.badge.plus") {
                    isCreateAlertPresented = true
                }
                Button("Clear All Data", systemImage: "trash", role: .destructive) {
                    isClearAlertPresented = true
                }
            }
        }
        .navigationTitle("Debug")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CloseButton()
            }
        }
        .alert(
            "Create sample data?",
            isPresented: $isCreateAlertPresented
        ) {
            Button("Cancel", systemImage: "xmark", role: .cancel) {}
            Button("Create", systemImage: "checkmark") { createSampleData() }
        } message: {
            Text("This will add example stuff to the list.")
        }
        .alert(
            "Clear all data?",
            isPresented: $isClearAlertPresented
        ) {
            Button("Cancel", systemImage: "xmark", role: .cancel) {}
            Button("Clear", systemImage: "trash", role: .destructive) { clearAllData() }
        } message: {
            Text("This will permanently delete all stuff.")
        }
    }

    private func createSampleData() {
        Logger(#file).info("Creating sample data")
        withAnimation {
            for stuff in SampleData.stuffs {
                let tagModels: [Tag] = stuff.tags.map {
                    Tag.findOrCreate(name: $0, in: modelContext)
                }
                _ = try? CreateStuffIntent.perform(
                    (
                        context: modelContext,
                        title: stuff.title,
                        note: stuff.note,
                        occurredAt: Date.now,
                        tags: tagModels
                    )
                )
            }
        }
        Logger(#file).notice("Sample data created")
    }

    private func clearAllData() {
        Logger(#file).info("Clearing all data")
        withAnimation {
            let descriptor: FetchDescriptor<Stuff> = .init()
            let allStuffs = (try? modelContext.fetch(descriptor)) ?? []
            for stuff in allStuffs {
                try? DeleteStuffIntent.perform(stuff)
            }
        }
        Logger(#file).notice("All data cleared")
    }

    private var stuffCount: Int {
        let descriptor: FetchDescriptor<Stuff> = .init()
        return (try? modelContext.fetch(descriptor).count) ?? 0
    }
}

struct SampleData {
    struct StuffData {
        let title: String
        let note: String?
        let tags: [String]
    }

    static let stuffs: [StuffData] = [
        .init(
            title: String(localized: "Coffee Beans"),
            note: String(localized: "Order from the local roastery."),
            tags: [String(localized: "Groceries")]
        ),
        .init(
            title: String(localized: "Running Shoes"),
            note: String(localized: "Replace the worn-out pair."),
            tags: [String(localized: "Fitness")]
        ),
        .init(
            title: String(localized: "Conference Tickets"),
            note: String(localized: "WWDC 2025"),
            tags: [String(localized: "Work")]
        ),
        .init(
            title: String(localized: "Vacation Booking"),
            note: String(localized: "Reserve hotel and flights."),
            tags: [String(localized: "Travel")]
        ),
        .init(
            title: String(localized: "Birthday Gift"),
            note: String(localized: "Surprise for Alice."),
            tags: [String(localized: "Personal")]
        )
    ]
}

#Preview(traits: .sampleData) {
    NavigationStack {
        DebugListView()
    }
}
