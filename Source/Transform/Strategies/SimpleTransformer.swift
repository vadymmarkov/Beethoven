import AVFoundation

public struct SimpleTransformer: Transformer {

  public func transformBuffer(_ buffer: AVAudioPCMBuffer) -> Buffer {
//    let pointer = UnsafePointer<Float>(buffer.floatChannelData)
//    let elements = Array.fromUnsafePointer(pointer, count: Int(buffer.frameLength))

    let pointer = buffer.floatChannelData
    let elements = Array.fromUnsafePointer((pointer?.pointee)!, count:Int(buffer.frameLength))
    return Buffer(elements: elements)
  }
}
