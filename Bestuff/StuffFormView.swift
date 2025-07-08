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
            .navigationTitle(Text("Add Item"))
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
            let newItem = Stuff(title: title, category: category, note: note.isEmpty ? nil : note)
            modelContext.insert(newItem)
            dismiss()
        }
    }
}

#Preview {
    StuffFormView()
        .modelContainer(for: Stuff.self, inMemory: true)
}

