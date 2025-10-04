import AVFoundation
import Cocoa
import SwiftUI

@MainActor
class AudioRecorderManager: ObservableObject {
    @Published var isRecording = false
    @Published var lastTranscription: String?

    private var recorder: Recorder?
    private var apiClient: WhisperAPIClient?
    private var keyListener: KeyListener?

    init() {
        setupAPIClient()
        setupKeyboardMonitoring()
        requestMicrophonePermission()
    }

    deinit {}

    private func setupAPIClient() {
        let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
        if !apiKey.isEmpty {
            self.apiClient = WhisperAPIClient(apiKey: apiKey)
        } else {
            print("Warning: OPENAI_API_KEY not found in environment")
        }
    }

    private func setupKeyboardMonitoring() {
        keyListener = KeyListener(
            onStart: { [weak self] in
                Task { @MainActor in
                    self?.startRecording()
                }
            },
            onStop: { [weak self] in
                Task { @MainActor in
                    self?.stopRecording()
                }
            }
        )
        keyListener?.startListening()
    }

    private func requestMicrophonePermission() {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if !granted {
                print("Microphone permission denied")
            }
        }
    }

    private func startRecording() {
        guard !isRecording else { return }

        print("Starting recording...")
        isRecording = true
        recorder = Recorder()

        do {
            try recorder?.start()
            print("Recording started successfully")
        } catch {
            print("Failed to start recording: \(error)")
            isRecording = false
            handleRecordingError(error)
        }
    }

    private func stopRecording() {
        guard isRecording else { return }

        print("Stopping recording...")
        isRecording = false
        recorder?.stop()

        guard let fileURL = recorder?.filePath() else {
            print("Missing recorder file path")
            lastTranscription = "Recording failed"
            return
        }

        transcribeAudio(fileURL: fileURL)
    }

    private func transcribeAudio(fileURL: URL) {
        guard let api = apiClient else {
            print("API client not available")
            lastTranscription = "API client not configured"
            return
        }

        print("Sending to API...")
        let request = api.build_request(fileURL: fileURL)

        api.send_request(request: request) { [weak self] text in
            Task { @MainActor in
                if let text = text, !text.isEmpty {
                    print("Transcription received: \(text)")
                    self?.lastTranscription = text
                    self?.handleSuccessfulTranscription(text)
                } else {
                    print("Transcription failed or empty")
                    self?.lastTranscription = "Transcription failed"
                }
            }
        }
    }

    private func handleRecordingError(_ error: Error) {
        lastTranscription = "Recording error: \(error.localizedDescription)"
    }

    private func handleSuccessfulTranscription(_ text: String) {
        typeTextAtCursor(text)
    }

    private func typeTextAtCursor(_ text: String) {
        for char in text {
            let string = String(char)
            guard let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true),
                let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: false)
            else { continue }

            let unicode = UniChar(string.utf16.first!)
            keyDown.keyboardSetUnicodeString(stringLength: 1, unicodeString: [unicode])
            keyDown.post(tap: .cghidEventTap)

            keyUp.keyboardSetUnicodeString(stringLength: 1, unicodeString: [unicode])
            keyUp.post(tap: .cghidEventTap)
        }
    }

    func cleanup() {
        keyListener?.stopListening()
        recorder?.stop()
    }
}
