import Foundation
import AVFoundation

public protocol PitchEngineDelegate: class {
  func pitchEngineDidRecieveFrequency(pitchEngine: PitchEngine, frequency: Float)
}

public class PitchEngine {

  private let bufferSize: AVAudioFrameCount

  private lazy var audioInputProcessor: AudioInputProcessor = { [unowned self] in
    let audioInputProcessor = AudioInputProcessor(
      bufferSize: self.bufferSize,
      delegate: self
    )

    return audioInputProcessor
    }()

  private lazy var pitchDetector: PitchDetector = { [unowned self] in
    let pitchDetector = PitchDetector(
      sampleRate: 44100.0,
      lowBoundFrequency: 30.0,
      highBoundFrequency: 4500,
      delegate: self)

    return pitchDetector
    }()

  public init(bufferSize: AVAudioFrameCount = 2048) {
    self.bufferSize = bufferSize
  }
}

// MARK: - AudioInputProcessorDelegate

extension PitchEngine: AudioInputProcessorDelegate {

  public func audioInputProcessorDidReceiveSamples(samples: UnsafeMutablePointer<Int16>,
    framesCount: Int) {
      pitchDetector.addSamples(samples, framesCount: framesCount)
  }
}

// MARK: - PitchDetectorDelegate

extension PitchEngine: PitchDetectorDelegate {

  public func pitchDetectorDidUpdateFrequency(pitchDetector: PitchDetector, frequency: Float) {

  }
}


