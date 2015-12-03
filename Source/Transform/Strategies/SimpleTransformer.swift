import AVFoundation

public struct SimpleTransformer: TransformAware {

  public func transformBuffer(buffer: AVAudioPCMBuffer) -> Buffer {
    let pointer = UnsafePointer<Float>(buffer.floatChannelData)
    let elements = Array.fromUnsafePointer(pointer, count: Int(buffer.frameLength))

    return Buffer(elements: elements)
  }
}
