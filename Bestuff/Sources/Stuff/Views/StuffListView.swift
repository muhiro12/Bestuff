//
//  StuffListView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import Foundation
import SwiftData
import SwiftUI

struct StuffListView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \Stuff.occurredAt, order: .reverse)
    private var queriedStuffs: [Stuff]

    private let overrideStuffs: [Stuff]?

    @Binding private var selection: Stuff?
    @Binding private var searchText: String

    @State private var sort = StuffSort.occurredDateDescending
    @State private var completion = CompletionFilter.all
    @State private var minScore: Int?
    @State private var selectedLabel: Tag?
    @State private var availableLabels: [Tag] = []
    @State private var isRecapPresented = false
    @State private var isPlanPresented = false
    @State private var isTagPresented = false
    @State private var isAddPresented = false
    @State private var isSettingsPresented = false
    @State private var isDebugPresented = false
    @State private var isBulkPresented = false
    @State private var bulkSelectedIDs: Set<PersistentIdentifier> = []
    @State private var bulkAddLabelNames: String = ""
    @State private var bulkRemoveLabelNames: String = ""
    @AppStorage(BoolAppStorageKey.isDebugOn)
    private var isDebugOn

    init(
        stuffs: [Stuff]? = nil,
        selection: Binding<Stuff?>,
        searchText: Binding<String>
    ) {
        overrideStuffs = stuffs
        _selection = selection
        _searchText = searchText
    }

    private var stuffs: [Stuff] {
        overrideStuffs ?? queriedStuffs
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(filteredStuffs) { stuff in
                StuffRow()
                    .environment(stuff)
                    .tag(stuff)
                    .contextMenu(
                        menuItems: {
                            EditStuffButton()
                                .environment(stuff)
                            Button(
                                role: .destructive,
                                action: { delete(stuff) }
                            ) {
                                Label("Delete", systemImage: "trash")
                            }
                        },
                        preview: {
                            StuffView()
                                .environment(stuff)
                        }
                    )
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Best Stuff")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                AddStuffButton { isAddPresented = true }
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker("Sort", selection: $sort) {
                        ForEach(StuffSort.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    Divider()
                    Picker("Completion", selection: $completion) {
                        ForEach(CompletionFilter.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    Picker("Minimum Score", selection: Binding(get: {
                        minScore ?? -1
                    }, set: { newValue in
                        minScore = (newValue <= 0) ? nil : newValue
                    })) {
                        Text("Any").tag(-1)
                        Text("50+").tag(50)
                        Text("80+").tag(80)
                        Text("90+").tag(90)
                    }
                    Menu("Label") {
                        Button("Any") { selectedLabel = nil }
                        if availableLabels.isEmpty == false {
                            ForEach(availableLabels) { tag in
                                Button(tag.name) { selectedLabel = tag }
                            }
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Recap", systemImage: "calendar") {
                    Logger(#file).info("Recap button tapped")
                    isRecapPresented = true
                }
                .buttonStyle(.bordered)
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Plan", systemImage: "lightbulb") {
                    Logger(#file).info("Plan button tapped")
                    isPlanPresented = true
                }
                .buttonStyle(.bordered)
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Tags", systemImage: "tag") {
                    Logger(#file).info("Tags button tapped")
                    isTagPresented = true
                }
                .buttonStyle(.bordered)
            }
            ToolbarItem(placement: .secondaryAction) {
                SettingsButton { isSettingsPresented = true }
            }
            if isDebugOn {
                ToolbarItem(placement: .secondaryAction) {
                    DebugButton { isDebugPresented = true }
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Bulk", systemImage: "checklist") {
                    isBulkPresented = true
                }
            }
        }
        .sheet(isPresented: $isRecapPresented) {
            RecapNavigationView()
        }
        .sheet(isPresented: $isPlanPresented) {
            PlanNavigationView()
        }
        .sheet(isPresented: $isTagPresented) {
            TagNavigationView()
        }
        .sheet(isPresented: $isAddPresented) {
            NavigationStack { StuffFormView() }
        }
        .sheet(isPresented: $isSettingsPresented) {
            NavigationStack { SettingsListView() }
        }
        .sheet(isPresented: $isDebugPresented) {
            NavigationStack { DebugListView() }
        }
        .sheet(isPresented: $isBulkPresented) {
            NavigationStack {
                Form {
                    Section("Select Items") {
                        ForEach(filteredStuffs) { item in
                            HStack(spacing: 12) {
                                Image(systemName: isBulkSelected(item) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(isBulkSelected(item) ? .accent : .secondary)
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                    if let note = item.note, !note.isEmpty {
                                        Text(note)
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                toggleBulkSelection(item)
                            }
                        }
                    }
                    Section("Labels") {
                        TextField("Add labels (comma separated)", text: $bulkAddLabelNames)
                        TextField("Remove labels (comma separated)", text: $bulkRemoveLabelNames)
                    }
                    Section("Actions") {
                        Button("Mark Completed", systemImage: "checkmark.circle") {
                            bulkMarkCompleted()
                        }
                        .disabled(bulkSelectedIDs.isEmpty)

                        Button("Add Labels", systemImage: "tag") {
                            bulkAddLabels()
                        }
                        .disabled(bulkSelectedIDs.isEmpty || bulkAddLabelNames.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                        Button("Remove Labels", systemImage: "tag.slash") {
                            bulkRemoveLabels()
                        }
                        .disabled(bulkSelectedIDs.isEmpty || bulkRemoveLabelNames.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                        Button("Delete Selected", systemImage: "trash", role: .destructive) {
                            bulkDelete()
                        }
                        .disabled(bulkSelectedIDs.isEmpty)
                    }
                }
                .navigationTitle("Bulk Actions")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { isBulkPresented = false }
                    }
                }
            }
        }
        .task {
            availableLabels = (try? TagService.getAllLabels(context: modelContext)) ?? []
        }
    }

    private var filteredStuffs: [Stuff] {
        var result: [Stuff]
        if searchText.isEmpty {
            result = stuffs
        } else {
            result = stuffs.filter { model in
                model.title.localizedCaseInsensitiveContains(searchText) ||
                    (model.note?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        // Apply filters
        switch completion {
        case .all:
            break
        case .completed:
            result = result.filter(\.isCompleted)
        case .pending:
            result = result.filter { !$0.isCompleted }
        }
        if let threshold = minScore {
            result = result.filter { $0.score >= threshold }
        }
        if let label = selectedLabel {
            let id = label.id
            result = result.filter { stuff in
                (stuff.tags ?? []).contains { $0.id == id }
            }
        }
        return result.sorted { first, second in
            sort.areInIncreasingOrder(first, second)
        }
    }

    private func delete(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let stuff = stuffs[index]
                Logger(#file).info("Deleting stuff \(String(describing: stuff.id))")
                StuffService.delete(model: stuff)
                Logger(#file).notice("Deleted stuff \(String(describing: stuff.id))")
            }
        }
    }

    private func delete(_ stuff: Stuff) {
        guard let index = stuffs.firstIndex(where: {
            $0.id == stuff.id
        }) else {
            return
        }
        delete(at: IndexSet(integer: index))
    }

    private func isBulkSelected(_ model: Stuff) -> Bool {
        bulkSelectedIDs.contains(model.id)
    }

    private func toggleBulkSelection(_ model: Stuff) {
        let id = model.id
        if bulkSelectedIDs.contains(id) {
            bulkSelectedIDs.remove(id)
        } else {
            bulkSelectedIDs.insert(id)
        }
    }

    private func bulkMarkCompleted() {
        let targets = stuffs.filter { bulkSelectedIDs.contains($0.id) }
        for model in targets where model.isCompleted == false {
            let bonus = 15
            let newScore = max(0, min(100, model.score + bonus))
            model.update(score: newScore, isCompleted: true)
            modelContext.insert(model)
        }
        bulkSelectedIDs.removeAll()
        isBulkPresented = false
    }

    private func bulkDelete() {
        let targets = stuffs.filter { bulkSelectedIDs.contains($0.id) }
        withAnimation {
            for model in targets {
                StuffService.delete(model: model)
            }
        }
        bulkSelectedIDs.removeAll()
        isBulkPresented = false
    }

    private func bulkAddLabels() {
        let raw = bulkAddLabelNames
        let names = raw.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        guard names.isEmpty == false else { return }
        let targets = stuffs.filter { bulkSelectedIDs.contains($0.id) }
        for model in targets {
            TagService.addLabels(context: modelContext, to: model, names: names)
        }
        bulkSelectedIDs.removeAll()
        bulkAddLabelNames = ""
        isBulkPresented = false
    }

    private func bulkRemoveLabels() {
        let raw = bulkRemoveLabelNames
        let names = raw.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        guard names.isEmpty == false else { return }
        let targets = stuffs.filter { bulkSelectedIDs.contains($0.id) }
        for model in targets {
            TagService.removeLabels(from: model, names: names)
        }
        bulkSelectedIDs.removeAll()
        bulkRemoveLabelNames = ""
        isBulkPresented = false
    }
}

#Preview(traits: .sampleData) {
    NavigationStack {
        StuffListView(
            selection: .constant(nil),
            searchText: .constant("")
        )
    }
}
