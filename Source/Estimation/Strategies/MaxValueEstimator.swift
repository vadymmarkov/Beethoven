import Foundation

public class MaxValueEstimator: EstimationAware {

  public func estimateLocation(buffer: Buffer) throws -> Int {
    return try maxBufferIndex(buffer.elements)
  }
}
