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
    private enum TranscriptionError: Error {
        case failedToSetupRecognitionStream
        case invalidAudioDataType
        case localeNotSupported
    }

    private(set) var transcript = ""
    private(set) var isTranscribing = false

    private var finalizedTranscript = ""
    private var transcriber: SpeechTranscriber?
    private var analyzer: SpeechAnalyzer?
    private var analyzerFormat: AVAudioFormat?
    private var inputBuilder: AsyncStream<AnalyzerInput>.Continuation?
    private var inputSequence: AsyncStream<AnalyzerInput>?
    private var outputContinuation: AsyncStream<AVAudioPCMBuffer>.Continuation?
    private var recognitionTask: Task<Void, Never>?
    private var audioEngine = AVAudioEngine()

    func startTranscribing() async throws {
        guard !isTranscribing else {
            return
        }
        guard await isAuthorized() else {
            return
        }
#if os(iOS)
        try setUpAudioSession()
#endif
        try await setUpTranscriber()
        isTranscribing = true

        recognitionTask = Task { [weak self] in
            await self?.handleTranscriptionResults()
        }

        Task { [weak self] in
            guard let self else { return }
            do {
                for await buffer in try await audioStream() {
                    try await streamAudioToTranscriber(buffer)
                }
            } catch {
                stopTranscribing()
            }
        }
    }

    func stopTranscribing() {
        guard isTranscribing else {
            return
        }
        Task {
            await analyzer?.finalizeAndFinishThroughEndOfInput()
            await deallocate()
        }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        outputContinuation?.finish()
        inputBuilder?.finish()
        recognitionTask?.cancel()
        recognitionTask = nil
        isTranscribing = false
    }

    // MARK: - Private

    private func setUpTranscriber() async throws {
        transcriber = .init(
            locale: .current,
            transcriptionOptions: [],
            reportingOptions: [.volatileResults],
            attributeOptions: [.audioTimeRange]
        )

        guard let transcriber else {
            throw TranscriptionError.failedToSetupRecognitionStream
        }

        analyzer = SpeechAnalyzer(modules: [transcriber])
        analyzerFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber])

        do {
            try await ensureModel(transcriber: transcriber, locale: .current)
        } catch {
            print(error)
            return
        }

        (inputSequence, inputBuilder) = AsyncStream<AnalyzerInput>.makeStream()
        guard let inputSequence else {
            return
        }
        try await analyzer?.start(inputSequence: inputSequence)
    }

    private func ensureModel(transcriber: SpeechTranscriber, locale: Locale) async throws {
        guard await supported(locale: locale) else {
            throw TranscriptionError.localeNotSupported
        }
        if await installed(locale: locale) {
            return
        } else {
            try await downloadIfNeeded(for: transcriber)
        }
    }

    private func supported(locale: Locale) async -> Bool {
        let supported = await SpeechTranscriber.supportedLocales
        return supported.map { $0.identifier(.bcp47) }.contains(locale.identifier(.bcp47))
    }

    private func installed(locale: Locale) async -> Bool {
        let installed = await Set(SpeechTranscriber.installedLocales)
        return installed.map { $0.identifier(.bcp47) }.contains(locale.identifier(.bcp47))
    }

    private func downloadIfNeeded(for module: SpeechTranscriber) async throws {
        if let downloader = try await AssetInventory.assetInstallationRequest(supporting: [module]) {
            try await downloader.downloadAndInstall()
        }
    }

    private func deallocate() async {
        let allocated = await AssetInventory.allocatedLocales
        for locale in allocated {
            await AssetInventory.deallocate(locale: locale)
        }
    }

    private func handleTranscriptionResults() async {
        guard let transcriber else {
            return
        }
        do {
            for try await result in transcriber.results {
                let text = result.text
                if result.isFinal {
                    finalizedTranscript += text
                    transcript = finalizedTranscript
                } else {
                    transcript = finalizedTranscript + text
                }
            }
        } catch {
            print("speech recognition failed")
        }
    }

#if os(iOS)
    private func setUpAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .spokenAudio)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
#endif

    private func audioStream() async throws -> AsyncStream<AVAudioPCMBuffer> {
        audioEngine = .init()
        audioEngine.inputNode.installTap(
            onBus: 0,
            bufferSize: 4096,
            format: audioEngine.inputNode.outputFormat(forBus: 0)
        ) { [weak self] buffer, _ in
            self?.outputContinuation?.yield(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()

        return AsyncStream(AVAudioPCMBuffer.self, bufferingPolicy: .unbounded) { continuation in
            outputContinuation = continuation
        }
    }

    private func streamAudioToTranscriber(_ buffer: AVAudioPCMBuffer) async throws {
        guard let inputBuilder else {
            throw TranscriptionError.invalidAudioDataType
        }
        let input = AnalyzerInput(buffer: buffer)
        inputBuilder.yield(input)
    }

    private func isAuthorized() async -> Bool {
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

