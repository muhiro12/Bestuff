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
                            merge(groupIndex: index)
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
                    Button("Resolve All", systemImage: "wand.and.stars") { resolveAll() }
                        .disabled(groups.isEmpty || isResolving)
                }
            }
            .task(refresh)
        }
    }

    private func refresh() {
        groups = (try? TagService.duplicateGroups(context: modelContext)) ?? []
    }

    private func resolveAll() {
        isResolving = true
        do {
            try TagService.resolveDuplicates(context: modelContext)
            refresh()
            if groups.isEmpty {
                dismiss()
            }
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
