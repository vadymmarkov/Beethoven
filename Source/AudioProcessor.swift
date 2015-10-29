import AVFoundation

public protocol AudioProcessorDelegate: class {
  func audioProcessorDidReceiveSamples(samples: UnsafeMutablePointer<Int16>, framesCount: Int)
}

public class AudioProcessor {

  private let audioEngine = AVAudioEngine()
  public weak var delegate: AudioProcessorDelegate?

  public func start() {
    guard let inputNode = audioEngine.inputNode else { return }

    let bus = 0

    inputNode.installTapOnBus(bus, bufferSize: 2048, format:inputNode.inputFormatForBus(bus)) {
      (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
      dispatch_async(dispatch_get_main_queue()) {
        self.delegate?.audioProcessorDidReceiveSamples(buffer.int16ChannelData.memory, framesCount: Int(buffer.frameLength))
      }
    }

    audioEngine.prepare()

    do {
      try audioEngine.start()
      print("Star")
    } catch {
      print("Error")
    }
  }

  public func stop() {
    print("Stop")
    audioEngine.stop()
  }
}
