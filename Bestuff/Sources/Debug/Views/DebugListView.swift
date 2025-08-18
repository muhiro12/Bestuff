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
            for data in SampleData.stuffs {
                var tagModels: [Tag] = []
                // Labels
                for label in data.labels {
                    tagModels.append(Tag.findOrCreate(name: label, in: modelContext, type: .label))
                }
                // Period (optional)
                if let period = data.period {
                    tagModels.append(Tag.findOrCreate(name: period, in: modelContext, type: .period))
                }
                // Resources
                for resource in data.resources {
                    tagModels.append(Tag.findOrCreate(name: resource, in: modelContext, type: .resource))
                }

                let occurredAt = Calendar.current.date(byAdding: .day, value: data.occurredOffsetDays, to: .now) ?? .now

                let model = StuffService.create(
                    context: modelContext,
                    title: data.title,
                    note: data.note,
                    occurredAt: occurredAt,
                    tags: tagModels
                )
                model.update(score: data.score, isCompleted: data.isCompleted, lastFeedback: data.lastFeedback, source: data.source)
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
                StuffService.delete(model: stuff)
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
        let labels: [String]
        let period: String?
        let resources: [String]
        let score: Int
        let isCompleted: Bool
        let lastFeedback: Int?
        let source: String?
        let occurredOffsetDays: Int
    }

    static let stuffs: [StuffData] = [
        .init(
            title: String(localized: "Morning Run"),
            note: String(localized: "5km around the park."),
            labels: [String(localized: "Fitness")],
            period: String(localized: "This Week"),
            resources: [String(localized: "Shoes")],
            score: 60,
            isCompleted: true,
            lastFeedback: 10,
            source: "sample",
            occurredOffsetDays: -1
        ),
        .init(
            title: String(localized: "Read 'Atomic Habits'"),
            note: String(localized: "Chapters 1–3"),
            labels: [String(localized: "Leisure"), String(localized: "Learning")],
            period: nil,
            resources: [String(localized: "Book")],
            score: 70,
            isCompleted: false,
            lastFeedback: 10,
            source: "sample",
            occurredOffsetDays: -3
        ),
        .init(
            title: String(localized: "Team Meeting Agenda"),
            note: String(localized: "Outline topics for Monday."),
            labels: [String(localized: "Work")],
            period: String(localized: "Tomorrow"),
            resources: [String(localized: "Document")],
            score: 50,
            isCompleted: false,
            lastFeedback: nil,
            source: "sample",
            occurredOffsetDays: 1
        ),
        .init(
            title: String(localized: "Grocery Shopping"),
            note: String(localized: "Milk, eggs, bread, fruit."),
            labels: [String(localized: "Groceries")],
            period: nil,
            resources: [String(localized: "Checklist")],
            score: 40,
            isCompleted: false,
            lastFeedback: nil,
            source: "sample",
            occurredOffsetDays: 0
        ),
        .init(
            title: String(localized: "Plan Vacation"),
            note: String(localized: "Decide destination and budget."),
            labels: [String(localized: "Travel"), String(localized: "Personal")],
            period: String(localized: "Next Month"),
            resources: [String(localized: "Flight"), String(localized: "Hotel")],
            score: 55,
            isCompleted: false,
            lastFeedback: nil,
            source: "sample",
            occurredOffsetDays: 10
        ),
        .init(
            title: String(localized: "Learn SwiftUI"),
            note: String(localized: "Build a small sample app."),
            labels: [String(localized: "Learning"), String(localized: "Work")],
            period: nil,
            resources: [String(localized: "Article"), String(localized: "Video")],
            score: 80,
            isCompleted: false,
            lastFeedback: 1,
            source: "sample",
            occurredOffsetDays: -7
        ),
        .init(
            title: String(localized: "Renew Gym Membership"),
            note: nil,
            labels: [String(localized: "Fitness")],
            period: String(localized: "This Week"),
            resources: [],
            score: 30,
            isCompleted: false,
            lastFeedback: nil,
            source: "sample",
            occurredOffsetDays: 2
        ),
        .init(
            title: String(localized: "Birthday Gift for Alice"),
            note: String(localized: "Consider a book or flowers."),
            labels: [String(localized: "Personal")],
            period: nil,
            resources: [String(localized: "Gift")],
            score: 65,
            isCompleted: true,
            lastFeedback: 10,
            source: "sample",
            occurredOffsetDays: -14
        )
    ]
}

#Preview(traits: .sampleData) {
    NavigationStack {
        DebugListView()
    }
}
