import AVFoundation

public class OutputSignalTracker: SignalTrackingAware {

  enum Error: ErrorType {
    case InputNodeMissing
  }

  public weak var delegate: SignalTrackingDelegate?

  let bufferSize: AVAudioFrameCount
  let audioURL: NSURL

  private let audioEngine = AVAudioEngine()
  private var player = AVAudioPlayerNode()
  private let bus = 0

  // MARK: - Initialization

  public required init(audioURL: NSURL, bufferSize: AVAudioFrameCount = 2048, delegate: SignalTrackingDelegate? = nil) {
    self.audioURL = audioURL
    self.bufferSize = bufferSize
    self.delegate = delegate
  }

  // MARK: - Tracking

  public func start() throws {
    let audioFile = try AVAudioFile(forReading: audioURL)
    let audioFormat = audioFile.processingFormat
    let outputFormat = audioEngine.outputNode.outputFormatForBus(bus)

    audioEngine.attachNode(player)
    audioEngine.connect(player, to: audioEngine.mainMixerNode, format: audioFormat)
    player.scheduleFile(audioFile, atTime: nil, completionHandler: nil)

    audioEngine.outputNode.installTapOnBus(bus, bufferSize: bufferSize, format: outputFormat) { buffer, time in
      dispatch_async(dispatch_get_main_queue()) {
        self.delegate?.signalTracker(self, didReceiveBuffer: buffer, atTime: time)
      }
    }

    audioEngine.prepare()
    try audioEngine.start()
    player.play()
  }

  public func stop() {
    audioEngine.stop()
    audioEngine.reset()
  }
}
