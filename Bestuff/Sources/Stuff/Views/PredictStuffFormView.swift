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
    @State private var transcriber = SpeechTranscriptionManager()

    var body: some View {
        NavigationStack {
            Form {
                Section("Speech") {
                    TextEditor(text: $speech)
                        .frame(minHeight: 120, alignment: .topLeading)
                    HStack {
                        Spacer()
                        Button {
                            if transcriber.isRecording {
                                transcriber.stopRecording()
                            } else {
                                transcriber.startRecording()
                            }
                        } label: {
                            Image(systemName: transcriber.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .imageScale(.large)
                        }
                    }
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
            .onChange(of: transcriber.transcript) { _, newValue in
                speech = newValue
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
