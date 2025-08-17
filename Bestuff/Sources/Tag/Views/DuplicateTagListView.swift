import SwiftData
import SwiftUI

struct DuplicateTagListView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var duplicates: [Tag] = []
    @State private var isResolving = false

    var body: some View {
        NavigationStack {
            List(duplicates) { tag in
                Text(tag.name)
            }
            .navigationTitle("Duplicate Tags")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Resolve", systemImage: "wand.and.stars") {
                        resolve()
                    }
                    .disabled(duplicates.isEmpty || isResolving)
                }
            }
            .task(refresh)
        }
    }

    private func refresh() {
        duplicates = (try? TagService.findDuplicates(context: modelContext)) ?? []
    }

    private func resolve() {
        isResolving = true
        do {
            try TagService.resolveDuplicates(context: modelContext)
            refresh()
            if duplicates.isEmpty {
                dismiss()
            }
        } catch {
            // No-op: keep UI responsive without crashing
        }
        isResolving = false
    }
}

#Preview(traits: .sampleData) {
    DuplicateTagListView()
}
