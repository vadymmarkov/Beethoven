import AVFoundation

public protocol AudioInputProcessorDelegate: class {

  func audioInputProcessorDidReceiveSamples(
    samples: UnsafeMutablePointer<Int16>,
    framesCount: Int)
}

public class AudioInputProcessor {

  enum Error: ErrorType {
    case InputNodeMissing
  }

  public weak var delegate: AudioInputProcessorDelegate?

  private let audioEngine = AVAudioEngine()
  private let bus = 0

  public func start() throws {
    guard let inputNode = audioEngine.inputNode else {
      throw Error.InputNodeMissing
    }

    inputNode.installTapOnBus(bus, bufferSize: 44100, format:inputNode.inputFormatForBus(bus)) {
      buffer, time in

      dispatch_async(dispatch_get_main_queue()) {
        self.delegate?.audioInputProcessorDidReceiveSamples(buffer.int16ChannelData.memory,
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
