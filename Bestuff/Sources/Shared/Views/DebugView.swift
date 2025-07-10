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
          Label("Create Sample Data", systemImage: "doc.badge.plus")
        }
        Button(role: .destructive) {
          isClearAlertPresented = true
        } label: {
          Label("Clear All Data", systemImage: "trash")
        }
      }
    }
    .alert(
      "Create sample data?",
      isPresented: $isCreateAlertPresented
    ) {
      Button(role: .cancel) {} label: {
        Label("Cancel", systemImage: "xmark")
      }
      Button { createSampleData() } label: {
        Label("Create", systemImage: "checkmark")
      }
    } message: {
      Text("This will add example stuff to the list.")
    }
    .alert(
      "Clear all data?",
      isPresented: $isClearAlertPresented
    ) {
      Button(role: .cancel) {} label: {
        Label("Cancel", systemImage: "xmark")
      }
      Button(role: .destructive) { clearAllData() } label: {
        Label("Clear", systemImage: "trash")
      }
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
    .init(title: "Birthday Gift", category: "Personal", note: "Surprise for Alice."),
  ]
}

#Preview(traits: .sampleData) {
  NavigationStack { DebugView() }
}
