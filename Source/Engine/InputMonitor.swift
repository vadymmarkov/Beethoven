import AVFoundation

public protocol InputMonitorDelegate: class {

  func inputMonitor(inputMonitor: InputMonitor,
    didReceiveBuffer buffer: AVAudioPCMBuffer,
    atTime time: AVAudioTime)
}

public class InputMonitor {

  enum Error: ErrorType {
    case InputNodeMissing
  }

  public weak var delegate: InputMonitorDelegate?

  private let audioEngine = AVAudioEngine()
  private let bus = 0
  private let bufferSize: AVAudioFrameCount

  // MARK: - Initialization

  public init(bufferSize: AVAudioFrameCount = 2048, delegate: InputMonitorDelegate? = nil) {
    self.bufferSize = bufferSize
    self.delegate = delegate
  }

  // MARK: - Monitoring

  public func start() throws {
    guard let inputNode = audioEngine.inputNode else {
      throw Error.InputNodeMissing
    }

    let format = inputNode.inputFormatForBus(bus)

    inputNode.installTapOnBus(bus, bufferSize: bufferSize, format: format) { buffer, time in
      dispatch_async(dispatch_get_main_queue()) {
        self.delegate?.inputMonitor(self, didReceiveBuffer: buffer, atTime: time)
      }
    }

    audioEngine.prepare()
    try audioEngine.start()
  }

  public func stop() {
    audioEngine.stop()
  }
}
