import SwiftData
import SwiftUI

struct PredictStuffFormView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var speech = ""
    @State private var isProcessing = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Speech") {
                    TextEditor(text: $speech)
                        .frame(minHeight: 120, alignment: .topLeading)
                }
            }
            .navigationTitle(Text("Predict Stuff"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isProcessing {
                        ProgressView()
                    } else {
                        Button("Predict") {
                            predict()
                        }
                        .disabled(speech.isEmpty)
                    }
                }
            }
        }
    }

    private func predict() {
        isProcessing = true
        Task {
            _ = try? await PredictStuffIntent.perform((context: modelContext, speech: speech))
            isProcessing = false
            dismiss()
        }
    }
}

#Preview {
    PredictStuffFormView()
        .modelContainer(for: Stuff.self, inMemory: true)
}
