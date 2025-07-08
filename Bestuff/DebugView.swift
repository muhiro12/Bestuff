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
    @State private var isAlertPresented = false

    var body: some View {
        List {
            Section("Information") {
                HStack {
                    Text("App Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            }
            Section("Actions") {
                Button {
                    isAlertPresented = true
                } label: {
                    Text("Create Sample Data")
                }
            }
        }
        .alert(
            "Create sample data?",
            isPresented: $isAlertPresented
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Create") { createSampleData() }
        } message: {
            Text("This will add example items to the list.")
        }
        .navigationTitle(Text("Debug"))
    }

    private func createSampleData() {
        withAnimation {
            for item in SampleData.items {
                _ = try? CreateStuffIntent.perform(
                    (
                        context: modelContext,
                        title: item.title,
                        category: item.category,
                        note: item.note
                    )
                )
            }
        }
    }
}

struct SampleData {
    struct Item {
        let title: String
        let category: String
        let note: String?
    }

    static let items: [Item] = [
        .init(title: "Coffee Beans", category: "Groceries", note: "Order from the local roastery."),
        .init(title: "Running Shoes", category: "Fitness", note: "Replace the worn-out pair."),
        .init(title: "Conference Tickets", category: "Work", note: "WWDC 2025"),
        .init(title: "Vacation Booking", category: "Travel", note: "Reserve hotel and flights."),
        .init(title: "Birthday Gift", category: "Personal", note: "Surprise for Alice.")
    ]
}

#Preview {
    NavigationStack { DebugView() }
        .modelContainer(for: Stuff.self, inMemory: true)
}
