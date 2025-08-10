//
//  PredictStuffFormView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/10.
//

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
        Form {
            Section("Text") {
                TextEditor(text: $speech)
                    .frame(minHeight: 120, alignment: .topLeading)
            }
        }
        .navigationTitle("Predict Stuff")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CloseButton()
            }
            ToolbarItem(placement: .confirmationAction) {
                if isProcessing {
                    ProgressView()
                } else {
                    Button("Predict", systemImage: "wand.and.stars") {
                        Logger(#file).info("Predict button tapped")
                        predict()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                    .disabled(speech.isEmpty)
                }
            }
        }
    }

    private func predict() {
        Logger(#file).info("Starting prediction")
        isProcessing = true
        Task {
            _ = try? await PredictStuffIntent.perform((context: modelContext, speech: speech))
            isProcessing = false
            Logger(#file).notice("Prediction completed")
            dismiss()
        }
    }
}

#Preview {
    PredictStuffFormView()
        .modelContainer(for: Stuff.self, inMemory: true)
}
