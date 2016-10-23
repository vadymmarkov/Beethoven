import AVFoundation

public struct Config {

  public var bufferSize: AVAudioFrameCount
  public var estimationStrategy: EstimationStrategy
  public var audioURL: URL?

  // MARK: - Initialization

  public init(bufferSize: AVAudioFrameCount = 4096,
    estimationStrategy: EstimationStrategy = .yin,
    audioURL: URL? = nil) {
      self.bufferSize = bufferSize
      self.estimationStrategy = estimationStrategy
      self.audioURL = audioURL
  }
}
