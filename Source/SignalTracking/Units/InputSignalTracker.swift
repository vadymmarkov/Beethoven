import AVFoundation

public class InputSignalTracker: SignalTracker {

  public enum Error: ErrorType {
    case InputNodeMissing
  }

  public let bufferSize: AVAudioFrameCount
  public weak var delegate: SignalTrackerDelegate?

  private var audioEngine: AVAudioEngine!
  private let session = AVAudioSession.sharedInstance()
  private let bus = 0

  // MARK: - Initialization

  public required init(bufferSize: AVAudioFrameCount = 2048, delegate: SignalTrackerDelegate? = nil) {
    self.bufferSize = bufferSize
    self.delegate = delegate
  }

  // MARK: - Tracking

  public func start() throws {
    try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
    try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)

    audioEngine = AVAudioEngine()

    guard let inputNode = audioEngine.inputNode else {
      throw Error.InputNodeMissing
    }

    let format = inputNode.inputFormatForBus(bus)

    inputNode.installTapOnBus(bus, bufferSize: bufferSize, format: format) { buffer, time in
      dispatch_async(dispatch_get_main_queue()) {
        self.delegate?.signalTracker(self, didReceiveBuffer: buffer, atTime: time)
      }
    }

    audioEngine.prepare()
    try audioEngine.start()
  }

  public func stop() {
    audioEngine.stop()
    audioEngine.reset()
    audioEngine = nil
  }
}
