import AVFoundation

open class OutputSignalTracker: SignalTracker {

  open let bufferSize: AVAudioFrameCount
  open let audioURL: URL
  open weak var delegate: SignalTrackerDelegate?
  open var levelThreshold: Float?

  fileprivate var audioEngine: AVAudioEngine!
  fileprivate var audioPlayer: AVAudioPlayerNode!
  fileprivate let bus = 0

  // MARK: - Initialization

  public required init(audioURL: URL, bufferSize: AVAudioFrameCount = 2048, delegate: SignalTrackerDelegate? = nil) {
    self.audioURL = audioURL
    self.bufferSize = bufferSize
    self.delegate = delegate
  }

  // MARK: - Tracking

  open func start() throws {
    let session = AVAudioSession.sharedInstance()

    try session.setCategory(AVAudioSessionCategoryPlayback)

    audioEngine = AVAudioEngine()
    audioPlayer = AVAudioPlayerNode()

    let audioFile = try AVAudioFile(forReading: audioURL)

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

  open func stop() {
    audioPlayer.stop()
    audioEngine.stop()
    audioEngine.reset()
    audioEngine = nil
    audioPlayer = nil
  }
}
