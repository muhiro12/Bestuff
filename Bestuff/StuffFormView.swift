//
//  StuffFormView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftUI
import SwiftData

struct StuffFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var category = ""
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Information") {
                    TextField("Title", text: $title)
                    TextField("Category", text: $category)
                    TextField("Note", text: $note)
                }
            }
            .navigationTitle(Text("Add Stuff"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
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
                    note: note.isEmpty ? nil : note
                )
            )
            dismiss()
        }
    }
}

#Preview {
    StuffFormView()
        .modelContainer(for: Stuff.self, inMemory: true)
}

