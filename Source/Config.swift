import AVFoundation

public struct Config {
  
  public var bufferSize: AVAudioFrameCount
  public var transformStrategy: TransformStrategy
  public var estimationStrategy: EstimationStrategy
  public var audioURL: NSURL?

  // MARK: - Initialization

  public init(bufferSize: AVAudioFrameCount = 4096,
    transformStrategy: TransformStrategy = .FFT,
    estimationStrategy: EstimationStrategy = .HPS,
    audioURL: NSURL? = nil) {
      self.bufferSize = bufferSize
      self.transformStrategy = transformStrategy
      self.estimationStrategy = estimationStrategy
      self.audioURL = audioURL
  }
}
