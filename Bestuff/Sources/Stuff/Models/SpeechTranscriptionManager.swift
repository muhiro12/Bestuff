//
//  SpeechTranscriptionManager.swift
//  Bestuff
//
//  Created by Codex on 2025/07/10.
//

import AVFoundation
import Observation
import Speech

@Observable
final class SpeechTranscriptionManager {
    @MainActor @Published var transcript: String = ""
    @MainActor @Published var isRecording = false

    private var transcriber: SpeechTranscriber?
    private var analyzer: SpeechAnalyzer?
    private var analyzerFormat: AVAudioFormat?
    private var inputSequence: AsyncStream<AnalyzerInput>?
    private var inputBuilder: AsyncStream<AnalyzerInput>.Continuation?
    private var audioEngine = AVAudioEngine()
    private var outputContinuation: AsyncStream<AVAudioPCMBuffer>.Continuation?

    private var recognizerTask: Task<Void, Never>?

    func startRecording() {
        guard !isRecording else {
            return
        }
        isRecording = true
        recognizerTask = Task { try? await record() }
    }

    func stopRecording() {
        guard isRecording else {
            return
        }
        isRecording = false
        Task {
            await finalizeRecording()
        }
    }

    @MainActor
    private func finalizeRecording() async {
        do {
            try await analyzer?.finalizeAndFinishThroughEndOfInput()
        } catch {
            print("failed to finalize transcription")
        }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }

    private func record() async throws {
        guard await isAuthorized() else {
            print("user denied mic permission")
            return
        }
#if os(iOS)
        try setUpAudioSession()
#endif
        try await setUpTranscriber()
        for await buffer in try await audioStream() {
            try await streamAudioToTranscriber(buffer)
        }
    }

#if os(iOS)
    private func setUpAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .spokenAudio)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
#endif

    private func isAuthorized() async -> Bool {
#if os(iOS)
        let session = AVAudioSession.sharedInstance()
        return await withCheckedContinuation { continuation in
            session.requestRecordPermission { allowed in
                continuation.resume(returning: allowed)
            }
        }
#else
        return true
#endif
    }

    private func audioStream() async throws -> AsyncStream<AVAudioPCMBuffer> {
        try setupAudioEngine()
        audioEngine.inputNode.installTap(
            onBus: 0,
            bufferSize: 4096,
            format: audioEngine.inputNode.outputFormat(forBus: 0)
        ) { [weak self] buffer, _ in
            guard let self else {
                return
            }
            outputContinuation?.yield(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        return AsyncStream(AVAudioPCMBuffer.self, bufferingPolicy: .unbounded) { continuation in
            outputContinuation = continuation
        }
    }

    private func setupAudioEngine() throws {
        audioEngine.stop()
        audioEngine.reset()
    }

    private func setUpTranscriber() async throws {
        transcriber = SpeechTranscriber(
            locale: Locale.current,
            transcriptionOptions: [],
            reportingOptions: [.volatileResults],
            attributeOptions: [.audioTimeRange]
        )

        guard let transcriber else {
            throw TranscriptionError.failedToSetupRecognitionStream
        }

        analyzer = SpeechAnalyzer(modules: [transcriber])
        analyzerFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber])
        try await ensureModel(transcriber: transcriber, locale: Locale.current)

        (inputSequence, inputBuilder) = AsyncStream.makeStream()
        guard let inputSequence else {
            return
        }
        recognizerTask = Task {
            do {
                for try await result in transcriber.results {
                    await MainActor.run {
                        transcript += result.text
                    }
                }
            } catch {
                print("speech recognition failed")
            }
        }

        try await analyzer?.start(inputSequence: inputSequence)
    }

    private func streamAudioToTranscriber(_ buffer: AVAudioPCMBuffer) async throws {
        guard let inputBuilder else {
            return
        }
        let input = AnalyzerInput(buffer: buffer)
        inputBuilder.yield(input)
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
}

enum TranscriptionError: Error {
    case failedToSetupRecognitionStream
    case localeNotSupported
    case invalidAudioDataType
}
