//
//  SpeechRecognizer.swift
//  Bestuff
//
//  Created by Codex on 2025/07/09.
//

import AVFoundation
import Observation
import Speech
import SwiftUI

@Observable
final class SpeechRecognizer {
    private(set) var transcript = ""
    private(set) var isTranscribing = false

    private var audioEngine: AVAudioEngine?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?

    func startTranscribing() async throws {
        guard !isTranscribing else {
            return
        }
        guard await requestAuthorization() else {
            return
        }

        audioEngine = .init()
        guard let audioEngine else {
            return
        }

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = .init()
        guard let recognitionRequest else {
            return
        }
        recognitionRequest.shouldReportPartialResults = true

        isTranscribing = true
        recognitionTask = SFSpeechRecognizer()?.recognitionTask(
            with: recognitionRequest
        ) { [weak self] result, error in
            guard let self else {
                return
            }
            if let result {
                transcript = result.bestTranscription.formattedString
                if result.isFinal {
                    stopTranscribing()
                }
            }
            if error != nil {
                stopTranscribing()
            }
        }

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: format
        ) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    func stopTranscribing() {
        guard isTranscribing else {
            return
        }
        audioEngine?.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        isTranscribing = false
    }

    private func requestAuthorization() async -> Bool {
        if SFSpeechRecognizer.authorizationStatus() == .authorized {
            return true
        }
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

