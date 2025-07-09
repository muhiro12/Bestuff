//
//  EditStuffFormView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/10.
//

import SwiftData
import SwiftUI

struct EditStuffFormView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Bindable var stuff: Stuff

    @State private var title: String
    @State private var category: String
    @State private var note: String
    @State private var occurredAt: Date

    init(stuff: Stuff) {
        _stuff = Bindable(wrappedValue: stuff)
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
            stuff.title = title
            stuff.category = category
            stuff.note = note.isEmpty ? nil : note
            stuff.occurredAt = occurredAt
            dismiss()
        }
    }
}

#Preview(traits: .sampleData) {
    EditStuffFormView(
        stuff: .init(title: "Sample", category: "General")
    )
}
