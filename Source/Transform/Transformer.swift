import AVFoundation

protocol Transformer {
  func transform(buffer: AVAudioPCMBuffer) throws -> Buffer
}
