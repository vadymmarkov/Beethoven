import AVFoundation

public protocol AudioProcessorDelegate: class {
  func audioProcessorDidReceiveSamples(samples: UnsafeMutablePointer<Int16>, framesCount: Int)
}

public class AudioProcessor {

  enum InputError: ErrorType {
    case InputNodeMissing
  }

  public weak var delegate: AudioProcessorDelegate?

  private let audioEngine = AVAudioEngine()
  private let bus = 0

  public func start() throws {
    guard let inputNode = audioEngine.inputNode else {
      throw InputError.InputNodeMissing
    }

    inputNode.installTapOnBus(bus, bufferSize: 44100, format:inputNode.inputFormatForBus(bus)) {
      (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
      dispatch_async(dispatch_get_main_queue()) {
        self.delegate?.audioProcessorDidReceiveSamples(buffer.int16ChannelData.memory, framesCount: Int(buffer.frameLength))
      }
    }

    audioEngine.prepare()
    try audioEngine.start()
  }

  public func stop() {
    audioEngine.stop()
  }
}
