import AVFoundation

public class OutputSignalTracker: SignalTrackingAware {

  enum Error: ErrorType {
    case InputNodeMissing
  }

  public weak var delegate: SignalTrackingDelegate?

  private let audioEngine = AVAudioEngine()
  private let bus = 0
  private let bufferSize: AVAudioFrameCount

  // MARK: - Initialization

  public required init(bufferSize: AVAudioFrameCount = 2048, delegate: SignalTrackingDelegate? = nil) {
    self.bufferSize = bufferSize
    self.delegate = delegate
  }

  // MARK: - Tracking

  public func start() throws {
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
  }
}
