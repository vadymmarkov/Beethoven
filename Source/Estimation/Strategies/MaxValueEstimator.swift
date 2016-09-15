public struct MaxValueEstimator: LocationEstimator {

  public func estimateLocation(_ buffer: Buffer) throws -> Int {
    return try maxBufferIndex(buffer.elements)
  }
}
