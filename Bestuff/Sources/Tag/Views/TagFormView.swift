import SwiftData
import SwiftUI

struct TagFormView: View {
    @Environment(Tag.self)
    private var tag: Tag?
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var name = ""

    var body: some View {
        Form {
            TextField("Name", text: $name)
        }
        .navigationTitle(tag == nil ? "Add Tag" : "Edit Tag")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CloseButton()
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", systemImage: "tray.and.arrow.down", action: save)
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                    .disabled(name.isEmpty)
            }
        }
        .task {
            name = tag?.name ?? .empty
        }
    }

    private func save() {
        withAnimation {
            if let tag {
                Logger(#file).info("Updating tag \(String(describing: tag.id))")
                _ = try? UpdateTagIntent.perform((model: tag, name: name))
                Logger(#file).notice("Updated tag \(String(describing: tag.id))")
            } else {
                Logger(#file).info("Creating new tag")
                _ = try? CreateTagIntent.perform((context: modelContext, name: name))
                Logger(#file).notice("Created new tag")
            }
            dismiss()
        }
    }
}

#Preview(traits: .sampleData) {
    TagFormView()
        .modelContainer(for: Tag.self, inMemory: true)
}
