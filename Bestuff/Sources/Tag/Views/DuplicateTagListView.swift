import SwiftData
import SwiftUI

struct DuplicateTagListView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var groups: [[Tag]] = []
    @State private var isResolving = false
    @State private var selectedParents: [Int: Tag] = [:]
    @State private var confirmMergeIndex: Int?
    @State private var isConfirmingResolveAll = false
    @State private var toastMessage: String?

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(groups.enumerated()), id: \.offset) { index, group in
                    Section(header: Text(sectionTitleWithType(for: group))) {
                        ForEach(group) { tag in
                            HStack {
                                Text(tag.name)
                                Spacer()
                                if selectedParents[index]?.id == tag.id {
                                    Text("Parent")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedParents[index] = tag
                            }
                        }
                        Button("Merge", systemImage: "link") {
                            confirmMergeIndex = index
                        }
                        .disabled(selectedParents[index] == nil || isResolving)
                    }
                }
            }
            .navigationTitle("Duplicate Tags")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Resolve All", systemImage: "wand.and.stars") {
                        isConfirmingResolveAll = true
                    }
                    .disabled(groups.isEmpty || isResolving)
                }
            }
            .task(refresh)
            .alert("Merge duplicates?", isPresented: Binding(get: {
                confirmMergeIndex != nil
            }, set: { flag in
                if flag == false { confirmMergeIndex = nil }
            })) {
                Button("Merge", role: .destructive) {
                    if let index = confirmMergeIndex {
                        merge(groupIndex: index)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let index = confirmMergeIndex,
                   let parent = selectedParents[index] {
                    let name = parent.name
                    let childrenCount = max(0, (groups[safe: index]?.count ?? 0) - 1)
                    Text("This will merge \(childrenCount) duplicates into \"\(name)\" and remove them.")
                } else {
                    Text("This will merge the selected duplicate group.")
                }
            }
            .alert("Resolve all duplicates?", isPresented: $isConfirmingResolveAll) {
                Button("Resolve All", role: .destructive) {
                    resolveAll()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                let groupsCount = groups.count
                let dupCount = groups.reduce(0) { $0 + max(0, $1.count - 1) }
                Text("This will merge \(dupCount) duplicates across \(groupsCount) groups and remove them.")
            }
            .alert(toastMessage ?? "", isPresented: Binding(get: {
                toastMessage != nil
            }, set: { flag in
                if flag == false { toastMessage = nil }
            })) {
                Button("OK") {}
            }
        }
    }

    private func refresh() {
        groups = (try? TagService.duplicateGroups(context: modelContext)) ?? []
    }

    private func resolveAll() {
        isResolving = true
        do {
            let groupsCount = groups.count
            let dupCount = groups.reduce(0) { $0 + max(0, $1.count - 1) }
            try TagService.resolveDuplicates(context: modelContext)
            refresh()
            if groups.isEmpty {
                dismiss()
            }
            toastMessage = "Resolved \(dupCount) duplicates across \(groupsCount) groups."
            NotificationCenter.default.post(name: .tagDuplicatesDidChange, object: nil)
        } catch {
            // No-op: keep UI responsive without crashing
        }
        isResolving = false
    }

    private func merge(groupIndex: Int) {
        isResolving = true
        do {
            let group = groups[groupIndex]
            guard let parent = selectedParents[groupIndex] else {
                isResolving = false
                return
            }
            let children = group.filter { $0.id != parent.id }
            try TagService.mergeDuplicates(parent: parent, children: children)
            refresh()
            let mergedCount = max(0, group.count - 1)
            toastMessage = "Merged \(mergedCount) duplicates into \"\(parent.name)\"."
            NotificationCenter.default.post(name: .tagDuplicatesDidChange, object: nil)
        } catch {
            // No-op
        }
        isResolving = false
    }

    private func sectionTitle(for group: [Tag]) -> String {
        guard let first = group.first else { return "" }
        let others = max(0, group.count - 1)
        return "\(first.name) (\(others) dup)"
    }

    private func sectionTitleWithType(for group: [Tag]) -> String {
        guard let first = group.first else { return "" }
        let typeName: String
        switch first.type ?? .label {
        case .label:
            typeName = "Label"
        case .period:
            typeName = "Period"
        case .resource:
            typeName = "Resource"
        }
        let others = max(0, group.count - 1)
        return "\(typeName): \(first.name) (\(others) dup)"
    }
}

#Preview(traits: .sampleData) {
    DuplicateTagListView()
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        if indices.contains(index) {
            return self[index]
        }
        return nil
    }
}
