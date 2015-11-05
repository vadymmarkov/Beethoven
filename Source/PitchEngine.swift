import Foundation
import AVFoundation

public protocol PitchEngineDelegate: class {
  func pitchEngineDidRecievePitch(pitchEngine: PitchEngine, pitch: Pitch)
}

public class PitchEngine {

  public weak var delegate: PitchEngineDelegate?
  public var active = false

  private let bufferSize: AVAudioFrameCount
  private var frequencies = [Float]()

  private lazy var audioInputProcessor: AudioInputProcessor = { [unowned self] in
    let audioInputProcessor = AudioInputProcessor(
      bufferSize: self.bufferSize,
      delegate: self
    )

    return audioInputProcessor
    }()

  private lazy var frequencyDetector: FrequencyDetector = { [unowned self] in
    let frequencyDetector = FrequencyDetector(
      sampleRate: 44100.0,
      bufferSize: self.bufferSize,
      delegate: self)

    return frequencyDetector
    }()

  // MARK: - Initialization

  public init(bufferSize: AVAudioFrameCount = 2048, delegate: PitchEngineDelegate?) {
    self.bufferSize = bufferSize
    self.delegate = delegate
  }

  // MARK: - Processing

  public func start() {
    do {
      try audioInputProcessor.start()
      active = true
    } catch {}
  }

  public func stop() {
    audioInputProcessor.stop()
    frequencies = [Float]()
    active = false
  }

  // MARK: - Helpers

  private func averageFrequency(frequency: Float) -> Float {
    var result = frequency

    frequencies.insert(frequency, atIndex: 0)

    if frequencies.count > 22 {
      frequencies.removeAtIndex(frequencies.count - 1)
    }

    let count = frequencies.count

    if count > 1 {
      var sortedFrequencies = frequencies.sort { $0 > $1 }

      if count % 2 == 0 {
        let value1 = sortedFrequencies[count / 2 - 1]
        let value2 = sortedFrequencies[count / 2]
        result = (value1 + value2) / 2
      } else {
        result = sortedFrequencies[count / 2]
      }
    }

    return result
  }
}

// MARK: - AudioInputProcessorDelegate

extension PitchEngine: AudioInputProcessorDelegate {

  public func audioInputProcessorDidReceiveBuffer(buffer: AVAudioPCMBuffer) {
    frequencyDetector.readBuffer(buffer)
  }
}

// MARK: - FrequencyDetectorDelegate

extension PitchEngine: FrequencyDetectorDelegate {

  public func frequencyDetectorDidRetrieveFrequency(frequencyDetector: FrequencyDetector, frequency: Float) {
    let pitch = Pitch(frequency: averageFrequency(frequency))

    delegate?.pitchEngineDidRecievePitch(self, pitch: pitch)
  }
}
