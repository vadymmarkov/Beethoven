import AVFoundation

public protocol Transformer {

  func transformBuffer(_ buffer: AVAudioPCMBuffer) -> Buffer
}
