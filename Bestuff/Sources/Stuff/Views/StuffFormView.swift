//
//  StuffFormView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftData
import SwiftUI

struct StuffFormView: View {
    @Environment(Stuff.self)
    private var stuff: Stuff?
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var title = ""
    @State private var category = ""
    @State private var note = ""
    @State private var occurredAt = Date.now

    var body: some View {
        Form {
            Section("Information") {
                TextField("Title", text: $title)
                TextField("Category", text: $category)
                TextField("Note", text: $note)
                DatePicker(
                    "Date",
                    selection: $occurredAt,
                    displayedComponents: .date
                )
            }
            Section("Options") {
                PredictStuffButton()
            }
        }
        .navigationTitle(stuff == nil ? "Add Stuff" : "Edit Stuff")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CloseButton()
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", systemImage: "tray.and.arrow.down", action: save)
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                    .disabled(title.isEmpty)
            }
        }
        .task {
            title = stuff?.title ?? .empty
            category = stuff?.category ?? .empty
            note = stuff?.note ?? .empty
            occurredAt = stuff?.occurredAt ?? .now
        }
    }

    private func save() {
        withAnimation {
            if let stuff {
                Logger(#file).info("Updating stuff \(String(describing: stuff.id))")
                _ = try? UpdateStuffIntent.perform(
                    (
                        model: stuff,
                        title: title,
                        category: category,
                        note: note.isEmpty ? nil : note,
                        occurredAt: occurredAt
                    )
                )
                Logger(#file).notice("Updated stuff \(String(describing: stuff.id))")
            } else {
                Logger(#file).info("Creating new stuff")
                _ = try? CreateStuffIntent.perform(
                    (
                        context: modelContext,
                        title: title,
                        category: category,
                        note: note.isEmpty ? nil : note,
                        occurredAt: occurredAt
                    )
                )
                Logger(#file).notice("Created new stuff")
            }
            dismiss()
        }
    }
}

#Preview(traits: .sampleData) {
    StuffFormView()
        .environment(
            Stuff.create(
                title: "Sample",
                category: "General",
                occurredAt: .now,
                createdAt: .now
            )
        )
}
