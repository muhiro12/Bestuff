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
                // Selected label chips
                if !selectedTags.isEmpty {
                    FlowLayout(alignment: .leading, spacing: 8) {
                        ForEach(Array(selectedTags).sorted { $0.name < $1.name }) { tag in
                            LabelChipView(title: tag.name) {
                                selectedTags.remove(tag)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                // Quick add label
                TextField(
                    "Add label",
                    text: $newTags
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                // Suggestions
                if let suggestions = try? TagService.suggestLabels(
                    context: modelContext,
                    prefix: newTags,
                    excluding: Array(selectedTags)
                ), !newTags.isEmpty, !suggestions.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestions) { tag in
                                Button(tag.name) {
                                    selectedTags.insert(tag)
                                    newTags = ""
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                // Tag picker (full list)
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
            let quickAdd = newTags
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            let newTagSet: Set<Tag> = Set(
                quickAdd.map { TagService.create(context: modelContext, name: $0, type: .label) }
            )
            selectedTags.formUnion(newTagSet)
            if let stuff {
                Logger(#file).info("Updating stuff \(String(describing: stuff.id))")
                _ = StuffService.update(
                    model: stuff,
                    title: title,
                    note: note.isEmpty ? nil : note,
                    occurredAt: occurredAt,
                    tags: Array(selectedTags)
                )
                Logger(#file).notice("Updated stuff \(String(describing: stuff.id))")
            } else {
                Logger(#file).info("Creating new stuff")
                _ = StuffService.create(
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
    let sample = StuffService.create(
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

// MARK: - LabelChipView & FlowLayout

private struct LabelChipView: View {
    let title: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.footnote)
            Button(role: .destructive) {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.footnote)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.thinMaterial, in: Capsule())
    }
}

private struct FlowLayout<Content: View>: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    @ViewBuilder let content: Content

    init(alignment: HorizontalAlignment = .leading, spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: spacing, alignment: .top)], spacing: spacing) {
            content
        }
    }
}
