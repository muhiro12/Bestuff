//
//  SpeechTranscriptionManager.swift
//  Bestuff
//
//  Created by Codex on 2025/07/10.
//

@preconcurrency import AVFoundation
import Observation
import Speech

@MainActor
@Observable
final class SpeechTranscriptionManager {
    private(set) var transcriptionError: Error?
    private(set) var transcript: String = ""
    private(set) var isRecording = false

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
        Logger(#file).info("Started recording")
        transcriptionError = nil
        recognizerTask = Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            do {
                try await record()
            } catch {
                transcriptionError = error
            }
        }
    }

    func stopRecording() {
        guard isRecording else {
            return
        }
        isRecording = false
        Logger(#file).info("Stopped recording")
        Task { @MainActor [weak self] in
            await self?.finalizeRecording()
        }
    }

    private func finalizeRecording() async {
        do {
            try await analyzer?.finalizeAndFinishThroughEndOfInput()
        } catch {
            Logger(#file).error("Failed to finalize transcription: \(error.localizedDescription)")
        }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }

    private func record() async throws {
        guard await isAuthorized() else {
            Logger(#file).error("User denied microphone permission")
            transcriptionError = TranscriptionError.microphonePermissionDenied
            return
        }

        try setUpAudioSession()

        try await setUpTranscriber()
        for await buffer in try audioStream() {
            try streamAudioToTranscriber(buffer)
        }
    }

    private func setUpAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .spokenAudio)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func isAuthorized() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { allowed in
                continuation.resume(returning: allowed)
            }
        }
    }

    private func audioStream() throws -> AsyncStream<AVAudioPCMBuffer> {
        try setupAudioEngine()
        audioEngine.inputNode.installTap(
            onBus: 0,
            bufferSize: 4_096,
            format: audioEngine.inputNode.outputFormat(forBus: 0)
        ) { [weak self] buffer, _ in
            Task { @MainActor [weak self, buffer] in
                guard let self else {
                    return
                }
                outputContinuation?.yield(buffer)
            }
        }

        audioEngine.prepare()
        try audioEngine.start()

        let streamContainer = AsyncStream.makeStream(
            of: AVAudioPCMBuffer.self,
            bufferingPolicy: .unbounded
        )
        outputContinuation = streamContainer.continuation
        return streamContainer.stream
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
                        transcript += .init(result.text.characters)
                    }
                }
            } catch {
                Logger(#file).error("Speech recognition failed: \(error.localizedDescription)")
            }
        }

        try await analyzer?.start(inputSequence: inputSequence)
    }

    private func streamAudioToTranscriber(_ buffer: AVAudioPCMBuffer) throws {
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
        }
        try await downloadIfNeeded(for: transcriber)
    }

    private func supported(locale: Locale) async -> Bool {
        let supported = await SpeechTranscriber.supportedLocales
        return supported.map {
            $0.identifier(.bcp47)
        }.contains(locale.identifier(.bcp47))
    }

    private func installed(locale: Locale) async -> Bool {
        let installed = await Set(SpeechTranscriber.installedLocales)
        return installed.map {
            $0.identifier(.bcp47)
        }.contains(locale.identifier(.bcp47))
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
    case microphonePermissionDenied
}

extension TranscriptionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedToSetupRecognitionStream:
            "Failed to set up speech recognition"
        case .localeNotSupported:
            "The current locale is not supported"
        case .invalidAudioDataType:
            "Received invalid audio data"
        case .microphonePermissionDenied:
            "Microphone access was denied"
        }
    }
}
