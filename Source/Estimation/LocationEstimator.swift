public protocol LocationEstimator: Estimator {

  func estimateLocation(_ buffer: Buffer) throws -> Int
}

public extension LocationEstimator {

  // MARK: - Default implementation

  var transformer: Transformer {
    return FFTTransformer()
  }

  func estimateFrequency(_ sampleRate: Float, buffer: Buffer) throws -> Float {
    let location = try estimateLocation(buffer)
    return estimateFrequency(sampleRate, location: location, bufferCount: buffer.count)
  }
}
