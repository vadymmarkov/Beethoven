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
  public var sampleRate: Float

  private var bufferLength: Int
  private var hanningWindow: UnsafeMutablePointer<Float>
  private var result: UnsafeMutablePointer<Float>
  private var buffer: UnsafeMutablePointer<Int16>
  private var samplesInBuffer: Int

  // MARK: - Initialization

  public init(sampleRate: Float,
    lowBoundFrequency: Int = Defaults.lowBoundFrequency,
    highBoundFrequency: Int = Defaults.highBoundFrequency,
    delegate: PitchDetectorDelegate? = nil) {
      self.sampleRate = sampleRate
      self.lowBoundFrequency = lowBoundFrequency
      self.highBoundFrequency = highBoundFrequency
      self.delegate = delegate

      bufferLength = Int(sampleRate) / lowBoundFrequency
      hanningWindow = UnsafeMutablePointer<Float>.alloc(bufferLength)
      result = UnsafeMutablePointer<Float>.alloc(bufferLength)
      buffer = UnsafeMutablePointer<Int16>.alloc(512)
      samplesInBuffer = 0

      vDSP_hann_window(hanningWindow, vDSP_Length(bufferLength), Int32(vDSP_HANN_NORM))
  }

  public func addSamples(samples: Int16, inNumberFrames frames: Int) {

  }
}
