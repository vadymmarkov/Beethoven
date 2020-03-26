import AVFoundation

final class OutputSignalTracker: SignalTracker {
  weak var delegate: SignalTrackerDelegate?
  var levelThreshold: Float?

  private let bufferSize: AVAudioFrameCount
  private let audioUrl: URL
  private var audioEngine: AVAudioEngine!
  private var audioPlayer: AVAudioPlayerNode!
  private let bus = 0

  var peakLevel: Float? {
    return 0.0
  }

  var averageLevel: Float? {
    return 0.0
  }

  var mode: SignalTrackerMode {
    return .playback
  }

  // MARK: - Initialization

  required init(audioUrl: URL,
                bufferSize: AVAudioFrameCount = 2048,
                delegate: SignalTrackerDelegate? = nil) {
    self.audioUrl = audioUrl
    self.bufferSize = bufferSize
    self.delegate = delegate
  }

  // MARK: - Tracking

  func start() throws {
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(AVAudioSession.Category.playback)

    audioEngine = AVAudioEngine()
    audioPlayer = AVAudioPlayerNode()

    let audioFile = try AVAudioFile(forReading: audioUrl)

    audioEngine.attach(audioPlayer)
    audioEngine.connect(audioPlayer, to: audioEngine.outputNode, format: audioFile.processingFormat)
    audioPlayer.scheduleFile(audioFile, at: nil, completionHandler: nil)

    audioEngine.outputNode.installTap(onBus: bus, bufferSize: bufferSize, format: nil) { buffer, time in
      DispatchQueue.main.async {
        self.delegate?.signalTracker(self, didReceiveBuffer: buffer, atTime: time)
      }
    }

    audioEngine.prepare()
    try audioEngine.start()

    audioPlayer.play()
  }

  func stop() {
    audioPlayer.stop()
    audioEngine.stop()
    audioEngine.reset()
    audioEngine = nil
    audioPlayer = nil
  }
}
