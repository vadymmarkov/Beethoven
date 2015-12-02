import AVFoundation

public class SimpleTransformer: TransformAware {

  // MARK: - Buffer Transformation

  public func transformBuffer(buffer: AVAudioPCMBuffer) -> Buffer {
    let pointer = UnsafePointer<Float>(buffer.floatChannelData)
    let elements = convert(Int(buffer.frameLength), data: pointer)

    return Buffer(elements: elements)
  }

  // MARK: - Helpers

  func convert<T>(count: Int, data: UnsafePointer<T>) -> [T] {
    let buffer = UnsafeBufferPointer(start: data, count: count);
    return Array(buffer)
  }
}
