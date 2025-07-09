//
//  StuffFormView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftData
import SwiftUI

struct StuffFormView: View {
    var stuff: Stuff?
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var title = ""
    @State private var category = ""
    @State private var note = ""
    @State private var occurredAt = Date.now

    init(stuff: Stuff? = nil) {
        self.stuff = stuff
        _title = State(initialValue: stuff?.title ?? "")
        _category = State(initialValue: stuff?.category ?? "")
        _note = State(initialValue: stuff?.note ?? "")
        _occurredAt = State(initialValue: stuff?.occurredAt ?? .now)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Information") {
                    TextField("Title", text: $title)
                    TextField("Category", text: $category)
                    TextField("Note", text: $note)
                    DatePicker("Date", selection: $occurredAt, displayedComponents: .date)
                }
            }
            .navigationTitle(Text(stuff == nil ? "Add Stuff" : "Edit Stuff"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                        .disabled(title.isEmpty)
                }
            }
        }
    }

    private func save() {
        withAnimation {
            if let stuff {
                stuff.title = title
                stuff.category = category
                stuff.note = note.isEmpty ? nil : note
                stuff.occurredAt = occurredAt
            } else {
                _ = try? CreateStuffIntent.perform(
                    (
                        context: modelContext,
                        title: title,
                        category: category,
                        note: note.isEmpty ? nil : note,
                        occurredAt: occurredAt
                    )
                )
            }
            dismiss()
        }
    }
}

#Preview(traits: .sampleData) {
    StuffFormView(
        stuff: Stuff(
            title: "Sample",
            category: "General",
            occurredAt: .now,
            createdAt: .now
        )
    )
}
