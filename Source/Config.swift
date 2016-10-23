import AVFoundation

public struct Config {

  public var bufferSize: AVAudioFrameCount
  public var estimationStrategy: EstimationStrategy
  public var audioUrl: URL?

  // MARK: - Initialization

  public init(bufferSize: AVAudioFrameCount = 4096,
    estimationStrategy: EstimationStrategy = .yin,
    audioUrl: URL? = nil) {
      self.bufferSize = bufferSize
      self.estimationStrategy = estimationStrategy
      self.audioUrl = audioUrl
  }
}
