import SwiftData
import SwiftUI

struct LabelEditorView: View {
    @Environment(Stuff.self)
    private var stuff
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var addText = ""
    @State private var removeText = ""

    var body: some View {
        Form {
            Section("Current Labels") {
                let labels = (stuff.tags ?? []).filter { $0.type == .label }
                if !labels.isEmpty {
                    ForEach(labels) { tag in
                        Text(tag.displayName)
                    }
                } else {
                    Text("No labels")
                        .foregroundStyle(.secondary)
                }
            }
            Section("Add Labels") {
                TextField("Comma separated", text: $addText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                if let suggestions = try? TagService.suggestLabels(
                    context: modelContext,
                    prefix: addText,
                    excluding: Array(stuff.tags ?? [])
                ), !addText.isEmpty, !suggestions.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestions) { tag in
                                Button(tag.name) {
                                    if addText.isEmpty {
                                        addText = tag.name
                                    } else {
                                        addText += ",\(tag.name)"
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                if addText.isEmpty,
                   let recents = try? TagService.mostUsedLabels(
                    context: modelContext,
                    excluding: Array(stuff.tags ?? []),
                    limit: 10
                   ), !recents.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(recents) { tag in
                                Button(tag.name) {
                                    if addText.isEmpty {
                                        addText = tag.name
                                    } else {
                                        addText += ",\(tag.name)"
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            Section("Remove Labels") {
                TextField("Comma separated", text: $removeText)
            }
        }
        .navigationTitle("Edit Labels")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CloseButton()
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", systemImage: "tray.and.arrow.down") {
                    applyChanges()
                    dismiss()
                }
                .disabled(addText.isEmpty && removeText.isEmpty)
            }
        }
    }

    private func applyChanges() {
        if addText.isEmpty == false {
            let names = addText.split(separator: ",").map { String($0) }
            TagService.addLabels(context: modelContext, to: stuff, names: names)
        }
        if removeText.isEmpty == false {
            let names = removeText.split(separator: ",").map { String($0) }
            TagService.removeLabels(from: stuff, names: names)
        }
    }
}

#Preview(traits: .sampleData) {
    NavigationStack {
        let schema: Schema = .init([Stuff.self, Tag.self])
        let configuration: ModelConfiguration = .init(schema: schema, isStoredInMemoryOnly: true)
        let container: ModelContainer = try! .init(for: schema, configurations: [configuration])
        let context = ModelContext(container)
        let sampleStuff = Stuff.create(title: "Sample")
        context.insert(sampleStuff)
        return LabelEditorView()
            .environment(sampleStuff)
            .modelContainer(container)
    }
}
