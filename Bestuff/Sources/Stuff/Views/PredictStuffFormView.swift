//
//  PredictStuffFormView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/10.
//

import SpeechWrapper
import SwiftData
import SwiftUI

struct PredictStuffFormView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var text = ""
    @State private var isRecording = false
    @State private var isProcessing = false

    private let speechClient = SpeechClient(settings: .init(useLegacy: true))

    var body: some View {
        Form {
            Section("Text") {
                TextEditor(text: $text)
                    .frame(minHeight: 120, alignment: .topLeading)
                Button("Speech", systemImage: "mic") {
                    // TODO: Modify
                    Task {
                        if isRecording {
                            isRecording = false
                            await speechClient.stop()
                        } else {
                            isRecording = true
                            do {
                                let stream = try await speechClient.stream()
                                for await text in stream {
                                    self.text = text
                                }
                            } catch {}
                            isRecording = false
                        }
                    }
                }
                .foregroundStyle(isRecording ? Color.secondary : Color.accentColor)
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
                    .disabled(text.isEmpty)
                }
            }
        }
    }

    private func predict() {
        Logger(#file).info("Starting prediction")
        isProcessing = true
        Task {
            _ = try? await StuffService.predict(context: modelContext, speech: text)
            isProcessing = false
            Logger(#file).notice("Prediction completed")
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        PredictStuffFormView()
    }
    .modelContainer(for: Stuff.self, inMemory: true)
}
