import Foundation

@main
struct WhisperGhost {
    static func main() {
        let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
        if apiKey.isEmpty {
            print("Missing OPENAI_API_KEY environment variable.")
            return
        }

        let recorder = Recorder()
        print("Press ENTER to start recording...")
        _ = readLine()
        do {
            try recorder.start()
        } catch {
            print("Failed to start recording: \(error)")
            return
        }
        print("Recording... Press ENTER to stop.")
        _ = readLine()
        recorder.stop()
        print("Recording saved at \(recorder.filePath().path)")

        let api = WhisperAPIClient(apiKey: apiKey)
        let request = api.build_request(fileURL: recorder.filePath())
        api.send_request(request: request) { text in
            if let text = text {
                print("Transcription: \(text)")
            } else {
                print("Failed to transcribe.")
            }
            exit(EXIT_SUCCESS)
        }

        RunLoop.main.run()
    }
}
