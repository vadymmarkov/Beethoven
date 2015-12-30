import AVFoundation

public class OutputSignalTracker: SignalTracker {

  public let bufferSize: AVAudioFrameCount
  public let audioURL: NSURL
  public weak var delegate: SignalTrackerDelegate?

  private var audioEngine: AVAudioEngine!
  private var audioPlayer: AVAudioPlayerNode!
  private let bus = 0

  // MARK: - Initialization

  public required init(audioURL: NSURL, bufferSize: AVAudioFrameCount = 2048, delegate: SignalTrackerDelegate? = nil) {
    self.audioURL = audioURL
    self.bufferSize = bufferSize
    self.delegate = delegate
  }

  // MARK: - Tracking

  public func start() throws {
    let session = AVAudioSession.sharedInstance()

    try session.setCategory(AVAudioSessionCategoryPlayback)

    audioEngine = AVAudioEngine()
    audioPlayer = AVAudioPlayerNode()

    let audioFile = try AVAudioFile(forReading: audioURL)

    audioEngine.attachNode(audioPlayer)
    audioEngine.connect(audioPlayer, to: audioEngine.outputNode, format: audioFile.processingFormat)
    audioPlayer.scheduleFile(audioFile, atTime: nil, completionHandler: nil)

    audioEngine.outputNode.installTapOnBus(bus, bufferSize: bufferSize, format: nil) {
      buffer, time in

      dispatch_async(dispatch_get_main_queue()) {
        self.delegate?.signalTracker(self, didReceiveBuffer: buffer, atTime: time)
      }
    }

    audioEngine.prepare()
    try audioEngine.start()

    audioPlayer.play()
  }

  public func stop() {
    audioPlayer.stop()
    audioEngine.stop()
    audioEngine.reset()
    audioEngine = nil
    audioPlayer = nil
  }
}
