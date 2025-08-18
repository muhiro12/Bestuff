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
    @State private var selectedType: TagType = .label

    var body: some View {
        Form {
            Section("Details") {
                TextField("Name", text: $name)
                Picker("Type", selection: $selectedType) {
                    Text("Label").tag(TagType.label)
                    Text("Period").tag(TagType.period)
                    Text("Resource").tag(TagType.resource)
                }
            }
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
            selectedType = tag?.type ?? .label
        }
    }

    private func save() {
        withAnimation {
            if let tag {
                Logger(#file).info("Updating tag \(String(describing: tag.id))")
                _ = TagService.update(model: tag, name: name)
                if tag.type != selectedType {
                    tag.update(type: selectedType)
                }
                Logger(#file).notice("Updated tag \(String(describing: tag.id))")
            } else {
                Logger(#file).info("Creating new tag")
                _ = TagService.create(context: modelContext, name: name, type: selectedType)
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
