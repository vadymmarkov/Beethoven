import AVFoundation

public protocol Transformer {
  func transform(buffer: AVAudioPCMBuffer) throws -> Buffer
}
