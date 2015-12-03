import AVFoundation

public struct Config {
  var bufferSize: AVAudioFrameCount
  var transformStrategy: TransformStrategy
  var estimationStrategy: EstimationStrategy
  var audioURL: NSURL?

  public init(bufferSize: AVAudioFrameCount = 4096, transformStrategy: TransformStrategy,
    estimationStrategy: EstimationStrategy, audioURL: NSURL? = nil) {
      self.bufferSize = bufferSize
      self.transformStrategy = transformStrategy
      self.estimationStrategy = estimationStrategy
      self.audioURL = audioURL
  }
}
