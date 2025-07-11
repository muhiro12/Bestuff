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
        .navigationTitle(Text("Debug"))
    }

    private func createSampleData() {
        Logger(#file).info("Creating sample data")
        withAnimation {
            for stuff in SampleData.stuffs {
                _ = try? CreateStuffIntent.perform(
                    (
                        context: modelContext,
                        title: stuff.title,
                        category: stuff.category,
                        note: stuff.note,
                        occurredAt: .now
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
        let category: String
        let note: String?
    }

    static let stuffs: [StuffData] = [
        .init(title: "Coffee Beans", category: "Groceries", note: "Order from the local roastery."),
        .init(title: "Running Shoes", category: "Fitness", note: "Replace the worn-out pair."),
        .init(title: "Conference Tickets", category: "Work", note: "WWDC 2025"),
        .init(title: "Vacation Booking", category: "Travel", note: "Reserve hotel and flights."),
        .init(title: "Birthday Gift", category: "Personal", note: "Surprise for Alice.")
    ]
}

#Preview(traits: .sampleData) {
    NavigationStack {
        DebugListView()
    }
}
