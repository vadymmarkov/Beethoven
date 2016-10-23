import AVFoundation

public struct Config {

  public var bufferSize: AVAudioFrameCount
  public var estimator: Estimator.Type
  public var audioURL: URL?

  // MARK: - Initialization

  public init(bufferSize: AVAudioFrameCount = 4096,
    estimator: Estimator.Type = YINEstimator.self,
    audioURL: URL? = nil) {
      self.bufferSize = bufferSize
      self.estimator = estimator
      self.audioURL = audioURL
  }
}
