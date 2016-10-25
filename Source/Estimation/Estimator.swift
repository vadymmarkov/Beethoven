protocol Estimator {
  var transformer: Transformer { get }

  func estimateFrequency(sampleRate: Float, buffer: Buffer) throws -> Float
  func estimateFrequency(sampleRate: Float, location: Int, bufferCount: Int) -> Float
}

extension Estimator {

  // MARK: - Default implementation

  func estimateFrequency(sampleRate: Float, location: Int, bufferCount: Int) -> Float {
    return Float(location) * sampleRate / (Float(bufferCount) * 2)
  }

  // MARK: - Helpers

  func maxBufferIndex(from buffer: [Float]) throws -> Int {
    guard buffer.count > 0 else {
      throw EstimationError.emptyBuffer
    }

    guard let index = buffer.maxIndex else {
      throw EstimationError.unknownMaxIndex
    }

    return index
  }

  func sanitize(location: Int, reserveLocation: Int, elements: [Float]) -> Int {
    return location >= 0 && location < elements.count
      ? location
      : reserveLocation
  }
}
