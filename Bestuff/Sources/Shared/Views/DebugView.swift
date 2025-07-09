//
//  DebugView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/09.
//

import SwiftData
import SwiftUI

struct DebugView: View {
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
                    Text("Stored Items")
                    Spacer()
                    Text("\(stuffCount)")
                        .foregroundStyle(.secondary)
                }
            }
            Section("Actions") {
                Button {
                    isCreateAlertPresented = true
                } label: {
                    Text("Create Sample Data")
                }
                Button(role: .destructive) {
                    isClearAlertPresented = true
                } label: {
                    Text("Clear All Data")
                }
            }
        }
        .alert(
            "Create sample data?",
            isPresented: $isCreateAlertPresented
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Create") { createSampleData() }
        } message: {
            Text("This will add example stuff to the list.")
        }
        .alert(
            "Clear all data?",
            isPresented: $isClearAlertPresented
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) { clearAllData() }
        } message: {
            Text("This will permanently delete all stuff.")
        }
        .navigationTitle(Text("Debug"))
    }

    private func createSampleData() {
        withAnimation {
            for stuff in SampleData.stuffs {
                _ = try? CreateStuffIntent.perform(
                    (
                        context: modelContext,
                        title: stuff.title,
                        category: stuff.category,
                        note: stuff.note,
                        occurredAt: stuff.occurredAt
                    )
                )
            }
        }
    }

    private func clearAllData() {
        withAnimation {
            let descriptor: FetchDescriptor<Stuff> = .init()
            let allStuffs = (try? modelContext.fetch(descriptor)) ?? []
            for stuff in allStuffs {
                try? DeleteStuffIntent.perform(stuff)
            }
        }
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
        let occurredAt: Date = .now.addingTimeInterval(.init(60 * 60 * 24 * Int.random(in: 0...365)))
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
    NavigationStack { DebugView() }
}
