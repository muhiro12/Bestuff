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

    @AppStorage(BoolAppStorageKey.isDebugOn)
    private var isDebugOn

    @State private var title = ""
    @State private var newTags = ""
    @State private var note = ""
    @State private var occurredAt = Date.now
    @State private var selectedTags: Set<Tag> = []
    @State private var isTagPickerPresented = false
    @State private var isDebugDialogPresented = false

    var body: some View {
        Form {
            Section("Information") {
                TextField("Title", text: $title)
                TextField("Note", text: $note)
                DatePicker(
                    "Date",
                    selection: $occurredAt,
                    displayedComponents: .date
                )
            }
            Section("Tags") {
                TextField(
                    "New Tags (comma separated)",
                    text: $newTags
                )
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
                Button(action: cancel) {
                    Text("Cancel")
                }
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
            note = stuff?.note ?? .empty
            occurredAt = stuff?.occurredAt ?? .now
            selectedTags = Set(stuff?.tags ?? [])
        }
        .sheet(isPresented: $isTagPickerPresented) {
            NavigationStack {
                TagPickerListView(selection: $selectedTags)
            }
        }
        .confirmationDialog(
            "Debug",
            isPresented: $isDebugDialogPresented
        ) {
            Button("OK", role: .destructive) {
                isDebugOn = true
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you really going to use DebugMode?")
        }
    }

    private func save() {
        withAnimation {
            let newTagSet: Set<Tag> = Set(
                newTags
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                    .compactMap { try? TagService.create(context: modelContext, name: $0) }
            )
            selectedTags.formUnion(newTagSet)
            if let stuff {
                Logger(#file).info("Updating stuff \(String(describing: stuff.id))")
                _ = try? StuffService.update(
                    model: stuff,
                    title: title,
                    note: note.isEmpty ? nil : note,
                    occurredAt: occurredAt,
                    tags: Array(selectedTags)
                )
                Logger(#file).notice("Updated stuff \(String(describing: stuff.id))")
            } else {
                Logger(#file).info("Creating new stuff")
                _ = try? StuffService.create(
                    context: modelContext,
                    title: title,
                    note: note.isEmpty ? nil : note,
                    occurredAt: occurredAt,
                    tags: Array(selectedTags)
                )
                Logger(#file).notice("Created new stuff")
            }
            dismiss()
        }
    }

    private func cancel() {
        if title == "Enable Debug" {
            title = .empty
            isDebugDialogPresented = true
            return
        }
        dismiss()
    }
}

#Preview(traits: .sampleData) {
    let schema: Schema = .init([Stuff.self])
    let configuration: ModelConfiguration = .init(schema: schema, isStoredInMemoryOnly: true)
    let container: ModelContainer = try! .init(for: schema, configurations: [configuration])
    let context: ModelContext = .init(container)
    let sample = try! StuffService.create(
        context: context,
        title: String(localized: "Sample"),
        note: nil,
        occurredAt: .now,
        tags: []
    )
    return StuffFormView()
        .environment(sample)
        .modelContainer(container)
}
