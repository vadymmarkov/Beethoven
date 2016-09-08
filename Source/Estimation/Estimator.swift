public protocol Estimator {

  func estimateFrequency(_ sampleRate: Float, buffer: Buffer) throws -> Float
  func estimateFrequency(_ sampleRate: Float, location: Int, bufferCount: Int) -> Float
}

extension Estimator {

  // MARK: - Default implementation

  public func estimateFrequency(_ sampleRate: Float, location: Int, bufferCount: Int) -> Float {
    return Float(location) * sampleRate / (Float(bufferCount) * 2)
  }

  // MARK: - Helpers

  func maxBufferIndex(_ buffer: [Float]) throws -> Int {
    guard buffer.count > 0 else {
      throw EstimationError.emptyBuffer
    }

    guard let index = buffer.maxIndex else {
      throw EstimationError.unknownMaxIndex
    }

    return index
  }

  func sanitize(_ location: Int, reserveLocation: Int, elements: [Float]) -> Int {
    return location >= 0 && location < elements.count
      ? location
      : reserveLocation
  }
}
