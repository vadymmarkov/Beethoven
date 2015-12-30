public struct MaxValueEstimator: LocationEstimator {

  public func estimateLocation(buffer: Buffer) throws -> Int {
    return try maxBufferIndex(buffer.elements)
  }
}
