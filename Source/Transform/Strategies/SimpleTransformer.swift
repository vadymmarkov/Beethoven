import AVFoundation

struct SimpleTransformer: Transformer {

  enum SimpleTransformerError: Error {
    case FloatChannelDataIsNil
  }

  func transform(buffer: AVAudioPCMBuffer) throws -> Buffer {
    guard let pointer = buffer.floatChannelData else {
      throw SimpleTransformerError.FloatChannelDataIsNil
    }

    let elements = Array.fromUnsafePointer(pointer.pointee, count:Int(buffer.frameLength))
    return Buffer(elements: elements)
  }
}
