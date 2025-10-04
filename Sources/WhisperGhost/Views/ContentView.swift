import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var audioManager: AudioRecorderManager

    var body: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                RecordingIndicatorView(isRecording: audioManager.isRecording)

                StatusTextView(isRecording: audioManager.isRecording)

                InstructionTextView()

                if let transcription = audioManager.lastTranscription {
                    TranscriptionResultView(transcription: transcription)
                }

                Spacer()
            }
            .padding(30)
        }
        .frame(minWidth: 300, minHeight: 250)
    }
}

struct RecordingIndicatorView: View {
    let isRecording: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isRecording ? Color.red : Color.green)
                .frame(width: 60, height: 60)
                .shadow(
                    color: isRecording ? .red.opacity(0.6) : .green.opacity(0.6),
                    radius: 15
                )

            if isRecording {
                Circle()
                    .stroke(Color.white.opacity(0.8), lineWidth: 3)
                    .frame(width: 60, height: 60)
                    .scaleEffect(isRecording ? 1.2 : 1.0)
                    .opacity(isRecording ? 0.0 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                        value: isRecording
                    )
            }
        }
    }
}

struct StatusTextView: View {
    let isRecording: Bool

    var body: some View {
        Text(isRecording ? "🎤 Recording..." : "Ready")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }
}

struct InstructionTextView: View {
    var body: some View {
        Text("Hold Fn to record")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 5)
    }
}

struct TranscriptionResultView: View {
    let transcription: String

    var body: some View {
        VStack(spacing: 5) {
            Divider()
                .padding(.vertical, 5)

            ScrollView {
                Text(transcription)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .textSelection(.enabled)
            }
            .frame(maxHeight: 150)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
