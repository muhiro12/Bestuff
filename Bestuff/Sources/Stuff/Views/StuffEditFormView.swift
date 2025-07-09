//
//  StuffEditFormView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/15.
//

import SwiftData
import SwiftUI

struct StuffEditFormView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    let stuff: Stuff

    @State private var title: String
    @State private var category: String
    @State private var note: String
    @State private var occurredAt: Date

    init(stuff: Stuff) {
        self.stuff = stuff
        _title = State(initialValue: stuff.title)
        _category = State(initialValue: stuff.category)
        _note = State(initialValue: stuff.note ?? "")
        _occurredAt = State(initialValue: stuff.occurredAt)
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
            .navigationTitle(Text("Edit Stuff"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .buttonStyle(.borderedProminent)
                        .tint(.pink)
                        .disabled(title.isEmpty)
                }
            }
        }
    }

    private func save() {
        withAnimation {
            _ = try? UpdateStuffIntent.perform(
                (
                    context: modelContext,
                    model: stuff,
                    title: title,
                    category: category,
                    note: note.isEmpty ? nil : note,
                    occurredAt: occurredAt
                )
            )
            dismiss()
        }
    }
}

#Preview(traits: .sampleData) {
    StuffEditFormView(
        stuff: Stuff(
            title: "Sample",
            category: "General",
            note: "Notes",
            occurredAt: .now
        )
    )
}
