import SwiftData
import SwiftUI

struct DuplicateTagListView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var groups: [[Tag]] = []
    @State private var isResolving = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(groups.enumerated()), id: \.offset) { _, group in
                    Section(header: Text(sectionTitle(for: group))) {
                        ForEach(group) { tag in
                            Text(tag.name)
                        }
                        Button("Merge", systemImage: "link") {
                            merge(group: group)
                        }
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

    private func merge(group: [Tag]) {
        isResolving = true
        do {
            try TagService.mergeDuplicates(tags: group)
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
}

#Preview(traits: .sampleData) {
    DuplicateTagListView()
}
