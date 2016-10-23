struct MaxValueEstimator: LocationEstimator {

  func estimateLocation(_ buffer: Buffer) throws -> Int {
    return try maxBufferIndex(buffer.elements)
  }
}
