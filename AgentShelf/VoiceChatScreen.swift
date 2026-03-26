import SwiftUI
import AVFoundation
import Combine

struct VoiceChatScreen: View {
    @StateObject private var session = VoiceSessionManager()

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                Text(session.statusText)
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 16))

                Spacer().frame(height: 48)

                ZStack {
                    if session.state == .listening || session.state == .speaking {
                        PulseRing(size: 200)
                        PulseRing(size: 160, delay: 0.3)
                    }

                    Circle()
                        .fill(Color.white.opacity(session.state == .idle ? 0.1 : 0.2))
                        .frame(width: 120, height: 120)

                    Circle()
                        .fill(session.state == .listening || session.state == .speaking
                              ? Color.white : Color.white.opacity(0.15))
                        .frame(width: 80, height: 80)

                    Image(systemName: session.state == .idle ? "phone.fill" : "xmark")
                        .font(.system(size: 28))
                        .foregroundColor(
                            session.state == .listening || session.state == .speaking
                            ? .black : .white
                        )
                }
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .contentShape(Circle())
                .onTapGesture {
                    if session.state == .idle {
                        session.start()
                    } else {
                        session.stop()
                    }
                }

                Spacer().frame(height: 48)

                if session.state != .idle {
                    Text("Tap to end")
                        .foregroundColor(.white.opacity(0.3))
                        .font(.system(size: 14))
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .navigationTitle("AgentShelf")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onDisappear {
            session.stop()
        }
    }
}

// MARK: - Pulse Animation

struct PulseRing: View {
    let size: CGFloat
    var delay: Double = 0

    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.15

    var body: some View {
        Circle()
            .fill(Color.white.opacity(opacity))
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    scale = 1.2
                    opacity = 0
                }
            }
    }
}

// MARK: - Voice State

enum VoiceState {
    case idle, connecting, listening, speaking
}

// MARK: - Voice Session Manager
// Auto-reconnect pattern matching Android:
// - WebSocket reconnects after each turn_complete
// - AudioEngine persists across reconnects
// - Mic gated by isSendingAudio for echo prevention

class VoiceSessionManager: ObservableObject {
    @Published var state: VoiceState = .idle

    var statusText: String {
        switch state {
        case .idle: return "Tap to connect"
        case .connecting: return "Connecting..."
        case .listening: return "Listening..."
        case .speaking: return "Speaking..."
        }
    }

    private var webSocketTask: URLSessionWebSocketTask?
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var isSendingAudio = false
    private var isRunning = false
    private let urlSession = URLSession(configuration: .default)

    private let inputSampleRate: Double = 16000
    private let outputSampleRate: Double = 24000
    private let wsURL = "wss://basavaprasad-digital-twin-882178443942.us-central1.run.app/voice"

    func start() {
        guard state == .idle else { return }
        state = .connecting
        isRunning = true
        isSendingAudio = false

        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.setupAudioAndConnect()
                } else {
                    self?.state = .idle
                    self?.isRunning = false
                }
            }
        }
    }

    func stop() {
        print("Session stopping")
        isRunning = false
        isSendingAudio = false

        let closeMsg = "{\"type\": \"close\"}"
        webSocketTask?.send(.string(closeMsg)) { _ in }
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil

        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        playerNode = nil

        state = .idle
    }

    // MARK: - Setup Audio (once per session)

    private func setupAudioAndConnect() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord,
                                         mode: .voiceChat,
                                         options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Audio session error: \(error)")
            state = .idle
            isRunning = false
            return
        }

        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        audioEngine = engine
        playerNode = player

        engine.attach(player)

        guard let outputFormat = AVAudioFormat(commonFormat: .pcmFormatInt16,
                                               sampleRate: outputSampleRate,
                                               channels: 1,
                                               interleaved: true) else { return }
        engine.connect(player, to: engine.mainMixerNode, format: outputFormat)

        // Mic tap — works on both simulator and real device
        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)

        guard let targetFormat = AVAudioFormat(commonFormat: .pcmFormatInt16,
                                               sampleRate: inputSampleRate,
                                               channels: 1,
                                               interleaved: true) else { return }

        guard let converter = AVAudioConverter(from: inputFormat, to: targetFormat) else {
            print("Failed to create audio converter")
            state = .idle
            isRunning = false
            return
        }

        inputNode.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] buffer, _ in
            guard let self = self, self.isRunning, self.isSendingAudio else { return }

            let ratio = self.inputSampleRate / inputFormat.sampleRate
            let frameCount = AVAudioFrameCount(Double(buffer.frameLength) * ratio)
            guard frameCount > 0 else { return }

            guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat,
                                                          frameCapacity: frameCount) else { return }

            var error: NSError?
            converter.convert(to: convertedBuffer, error: &error) { _, outStatus in
                outStatus.pointee = .haveData
                return buffer
            }

            guard error == nil, convertedBuffer.frameLength > 0 else { return }

            let byteCount = Int(convertedBuffer.frameLength) * 2
            let data = Data(bytes: convertedBuffer.int16ChannelData![0], count: byteCount)
            self.webSocketTask?.send(.data(data)) { _ in }
        }

        do {
            try engine.start()
            player.play()
        } catch {
            print("Engine start error: \(error)")
            state = .idle
            isRunning = false
            return
        }

        print("Audio engine started")

        // Connect first WebSocket
        connectWebSocket()
    }

    // MARK: - WebSocket (reconnects after each turn_complete)

    private func connectWebSocket() {
        guard isRunning else { return }

        print("Connecting WebSocket...")
        isSendingAudio = false

        let url = URL(string: wsURL)!
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()

        isSendingAudio = true
        DispatchQueue.main.async {
            self.state = .listening
        }
        print("WebSocket connected — mic enabled")

        receiveMessage()
    }

    private func receiveMessage() {
        guard isRunning else { return }

        webSocketTask?.receive { [weak self] result in
            guard let self = self, self.isRunning else { return }

            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("WS text: \(text)")
                    if text.contains("turn_complete") {
                        print("Turn complete — reconnecting for next turn")
                        self.isSendingAudio = false
                        self.webSocketTask?.cancel(with: .normalClosure, reason: nil)
                        self.webSocketTask = nil

                        // 300ms delay then reconnect (same as Android)
                        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) { [weak self] in
                            guard let self = self, self.isRunning else { return }
                            DispatchQueue.main.async {
                                self.state = .listening
                            }
                            self.connectWebSocket()
                        }
                    } else if text.contains("error") {
                        print("Server error: \(text)")
                    }

                case .data(let data):
                    // First audio chunk → pause mic (echo prevention)
                    if self.isSendingAudio {
                        self.isSendingAudio = false
                        print("AI speaking — mic paused")
                        DispatchQueue.main.async {
                            self.state = .speaking
                        }
                    }
                    self.playAudioData(data)

                @unknown default:
                    break
                }

                self.receiveMessage()

            case .failure(let error):
                print("WS error: \(error.localizedDescription)")
                // Auto-reconnect on failure
                if self.isRunning {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        guard let self = self, self.isRunning else { return }
                        DispatchQueue.main.async {
                            self.state = .connecting
                        }
                        self.connectWebSocket()
                    }
                }
            }
        }
    }

    // MARK: - Audio Playback

    private func playAudioData(_ data: Data) {
        guard let player = playerNode,
              let engine = audioEngine,
              engine.isRunning else { return }

        guard let format = AVAudioFormat(commonFormat: .pcmFormatInt16,
                                          sampleRate: outputSampleRate,
                                          channels: 1,
                                          interleaved: true) else { return }

        let frameCount = UInt32(data.count / 2)
        guard frameCount > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }

        buffer.frameLength = frameCount
        data.withUnsafeBytes { rawBuffer in
            if let baseAddress = rawBuffer.baseAddress {
                memcpy(buffer.int16ChannelData![0], baseAddress, data.count)
            }
        }

        player.scheduleBuffer(buffer, completionHandler: nil)
    }
}
