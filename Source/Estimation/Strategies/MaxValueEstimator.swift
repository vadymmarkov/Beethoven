final class MaxValueEstimator: LocationEstimator {
  func estimateLocation(buffer: Buffer) throws -> Int {
    return try maxBufferIndex(from: buffer.elements)
  }
}
