import AVFoundation

public struct SimpleTransformer: Transformer {

  enum SimpleTransformerError: Error {
    case FloatChannelDataIsNil
  }

  public func transform(buffer: AVAudioPCMBuffer) throws -> Buffer {
    guard let pointer = buffer.floatChannelData else {
      throw SimpleTransformerError.FloatChannelDataIsNil
    }

    let elements = Array.fromUnsafePointer(pointer.pointee, count:Int(buffer.frameLength))
    return Buffer(elements: elements)
  }
}
