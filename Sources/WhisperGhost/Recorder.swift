import AVFoundation
import Foundation

class Recorder {
    private var recorder: AVAudioRecorder?
    private let fileURL: URL

    init(filename: String = "recording.m4a") {
        self.fileURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(filename)
    }

    func start() throws {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitRateKey: 128000,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]
        recorder = try AVAudioRecorder(url: fileURL, settings: settings)
        recorder?.prepareToRecord()
        recorder?.record()
    }

    func stop() {
        recorder?.stop()
    }

    func filePath() -> URL {
        return fileURL
    }
}
