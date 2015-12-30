import AVFoundation

public protocol Transformer {

  func transformBuffer(buffer: AVAudioPCMBuffer) -> Buffer
}
