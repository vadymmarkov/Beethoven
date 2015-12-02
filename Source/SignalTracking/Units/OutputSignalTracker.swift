import AVFoundation

public class OutputSignalTracker: SignalTrackingAware {

  enum Error: ErrorType {
    case InputNodeMissing
  }

  public weak var delegate: SignalTrackingDelegate?

  let bufferSize: AVAudioFrameCount
  let audioURL: NSURL

  private let audioEngine = AVAudioEngine()
  private var audioPlayer = AVAudioPlayerNode()
  private let bus = 0

  // MARK: - Initialization

  public required init(audioURL: NSURL, bufferSize: AVAudioFrameCount = 2048, delegate: SignalTrackingDelegate? = nil) {
    self.audioURL = audioURL
    self.bufferSize = bufferSize
    self.delegate = delegate
  }

  // MARK: - Tracking

  public func start() throws {
    let session = AVAudioSession.sharedInstance()

    try session.setCategory(AVAudioSessionCategoryPlayback)
    try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)

    let audioFile = try AVAudioFile(forReading: audioURL)
    let outputFormat = audioEngine.outputNode.outputFormatForBus(bus)

    audioEngine.attachNode(audioPlayer)
    audioEngine.connect(audioPlayer, to: audioEngine.outputNode, format: nil)
    audioPlayer.scheduleFile(audioFile, atTime: nil, completionHandler: nil)

    audioEngine.outputNode.installTapOnBus(bus, bufferSize: bufferSize, format: outputFormat) { buffer, time in
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
  }
}
