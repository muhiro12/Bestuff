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
    @State private var selectedTags: Set<Tag> = []
    @State private var isTagPickerPresented = false

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
            Section("Tags") {
                Button {
                    Logger(#file).info("Tag picker button tapped")
                    isTagPickerPresented = true
                } label: {
                    HStack {
                        Text("Tags")
                        Spacer()
                        if selectedTags.isEmpty {
                            Text("None")
                                .foregroundStyle(.secondary)
                        } else {
                            Text(selectedTags.sorted { $0.name < $1.name }.map(\.name).joined(separator: ", "))
                                .foregroundStyle(.secondary)
                        }
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                    }
                }
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
            selectedTags = Set(stuff?.tags ?? [])
        }
        .sheet(isPresented: $isTagPickerPresented) {
            NavigationStack {
                TagPickerListView(selection: $selectedTags)
            }
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
                stuff.update(tags: Array(selectedTags))
                Logger(#file).notice("Updated stuff \(String(describing: stuff.id))")
            } else {
                Logger(#file).info("Creating new stuff")
                if let model = try? CreateStuffIntent.perform(
                    (
                        context: modelContext,
                        title: title,
                        category: category,
                        note: note.isEmpty ? nil : note,
                        occurredAt: occurredAt
                    )
                ) {
                    model.update(tags: Array(selectedTags))
                    Logger(#file).notice("Created new stuff")
                }
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
