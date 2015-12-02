import Foundation

public class MaxValueEstimator: EstimationAware {

  public func estimateLocation(transformResult: TransformResult, sampleRate: Float) -> Int {
    let buffer = transformResult.buffer

    guard let maxElement = buffer.maxElement(),
      maxIndex = buffer.indexOf(maxElement) else {
        return 0
    }

    return maxIndex
  }
}
