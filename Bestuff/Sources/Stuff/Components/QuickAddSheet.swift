import SwiftData
import SwiftUI

struct QuickAddSheet: View {
    @Environment(\.modelContext)
    private var modelContext

    @Binding var isPresented: Bool

    @State private var title: String = ""
    @State private var labelNames: String = ""
    @State private var pin: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Title", text: $title)
                }
                Section("Options") {
                    TextField("Labels (comma separated)", text: $labelNames)
                    Toggle("Pin", isOn: $pin)
                }
            }
            .navigationTitle("Quick Add")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedTitle.isEmpty == false else { return }

        let names = labelNames
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
        var tagModels: [Tag] = []
        for name in names {
            tagModels.append(Tag.findOrCreate(name: name, in: modelContext, type: .label))
        }
        let model = StuffService.create(
            context: modelContext,
            title: trimmedTitle,
            note: nil,
            occurredAt: .now,
            tags: tagModels
        )
        if pin {
            model.update(pinned: true)
            modelContext.insert(model)
        }
        isPresented = false
        title = ""
        labelNames = ""
        pin = false
    }
}

#Preview(traits: .sampleData) {
    QuickAddSheet(isPresented: .constant(true))
}
