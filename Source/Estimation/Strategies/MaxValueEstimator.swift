import Foundation

public class MaxValueEstimator: EstimationAware {

  public func estimateLocation(transformResult: TransformResult, sampleRate: Float) throws -> Int {
    return try maxBufferIndex(transformResult.buffer)
  }
}
