//
//  StuffFormView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftData
import SwiftUI

struct StuffFormView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var title = ""
    @State private var category = ""
    @State private var note = ""
    @State private var occurredAt = Date()

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
            .navigationTitle(Text("Add Stuff"))
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
            _ = try? CreateStuffIntent.perform(
                (
                    context: modelContext,
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
    StuffFormView()
}
