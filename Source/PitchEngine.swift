import Foundation

public protocol PitchEngineDelegate: class {
  func pitchEngineDidRecieveFrequency(pitchEngine: PitchEngine, frequency: Float)
}

public class PitchEngine {
}
