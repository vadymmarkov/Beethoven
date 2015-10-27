import Foundation
import AVFoundation
import Accelerate

public protocol PitchDetectorDelegate: class {
  func pitchDetectorDidUpdateFrequency(frequency: Double)
}

public class PitchDetector {

  public weak var delegate: PitchDetectorDelegate?
}
