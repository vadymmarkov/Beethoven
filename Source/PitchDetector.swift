import Foundation
import AVFoundation
import Accelerate

public protocol PitchDetectorDelegate: class {
  func pitchDetectorDidUpdateFrequency(frequency: Double)
}

public class PitchDetector {

  public struct Defaults {
    static let lowBoundFrequency = 40
    static let highBoundFrequency = 4500
  }

  public weak var delegate: PitchDetectorDelegate?

  public var isActive = false
  public var highBoundFrequency: Int = 0
  public var lowBoundFrequency: Int = 0
  public var sampleRate: Double

  // MARK: - Initialization

  public init(sampleRate: Double,
    lowBoundFrequency: Int = Defaults.lowBoundFrequency,
    highBoundFrequency: Int = Defaults.highBoundFrequency,
    delegate: PitchDetectorDelegate? = nil) {
      self.sampleRate = sampleRate
      self.lowBoundFrequency = lowBoundFrequency
      self.highBoundFrequency = highBoundFrequency
      self.delegate = delegate
  }

  public func addSamples(samples: Int16, inNumberFrames frames: Int) {

  }
}
