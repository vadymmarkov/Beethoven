public protocol LocationEstimator: Estimator {

  func estimateLocation(buffer: Buffer) throws -> Int
}

extension LocationEstimator {

  // MARK: - Default implementation

  public func estimateFrequency(sampleRate: Float, buffer: Buffer) throws -> Float {
    let location = try estimateLocation(buffer)
    return estimateFrequency(sampleRate, location: location, bufferCount: buffer.count)
  }
}
