import AVFoundation

class OutputSignalTracker: SignalTracker {

  weak var delegate: SignalTrackerDelegate?
  var levelThreshold: Float?

  fileprivate let bufferSize: AVAudioFrameCount
  fileprivate let audioUrl: URL

  fileprivate var audioEngine: AVAudioEngine!
  fileprivate var audioPlayer: AVAudioPlayerNode!
  fileprivate let bus = 0

  var peakLevel: Float? {
    get { return 0.0 }
  }

  var averageLevel: Float? {
    get { return 0.0 }
  }

  // MARK: - Initialization

  required init(audioUrl: URL, bufferSize: AVAudioFrameCount = 2048,
                delegate: SignalTrackerDelegate? = nil) {
    self.audioUrl = audioUrl
    self.bufferSize = bufferSize
    self.delegate = delegate
  }

  // MARK: - Tracking

  func start() throws {
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(AVAudioSessionCategoryPlayback)

    audioEngine = AVAudioEngine()
    audioPlayer = AVAudioPlayerNode()

    let audioFile = try AVAudioFile(forReading: audioUrl)

    audioEngine.attach(audioPlayer)
    audioEngine.connect(audioPlayer, to: audioEngine.outputNode, format: audioFile.processingFormat)
    audioPlayer.scheduleFile(audioFile, at: nil, completionHandler: nil)

    audioEngine.outputNode.installTap(onBus: bus, bufferSize: bufferSize, format: nil) {
      buffer, time in

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
