import Foundation

protocol EstimationAware {

  func estimateLocation(transformResult: TransformResult, sampleRate: Float) -> Int
}
