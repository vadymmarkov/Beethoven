import AVFoundation

public protocol AudioInputProcessorDelegate: class {

  func audioInputProcessorDidReceiveSamples(
    samples: UnsafeMutablePointer<Float>,
    framesCount: Int)
}

public class AudioInputProcessor {

  enum Error: ErrorType {
    case InputNodeMissing
  }

  public weak var delegate: AudioInputProcessorDelegate?

  private let audioEngine = AVAudioEngine()
  private let bus = 0
  private let bufferSize: AVAudioFrameCount

  // MARK: - Initialization

  public init(bufferSize: AVAudioFrameCount = 2048, delegate: AudioInputProcessorDelegate? = nil) {
    self.bufferSize = bufferSize
    self.delegate = delegate
  }

  // MARK: - Processing

  public func start() throws {
    guard let inputNode = audioEngine.inputNode else {
      throw Error.InputNodeMissing
    }

    let format = inputNode.inputFormatForBus(bus)

    inputNode.installTapOnBus(bus, bufferSize: bufferSize, format: format) { buffer, time in
      dispatch_async(dispatch_get_main_queue()) {
        self.delegate?.audioInputProcessorDidReceiveSamples(buffer.floatChannelData.memory,
          framesCount: Int(buffer.frameLength))
      }
    }

    audioEngine.prepare()
    try audioEngine.start()
  }

  public func stop() {
    audioEngine.stop()
  }
}
