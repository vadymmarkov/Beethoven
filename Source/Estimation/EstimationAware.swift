import Foundation

protocol EstimationAware {

  func estimateLocation(transformResult: TransformResult, sampleRate: Float) -> Int
}

extension EstimationAware {

  func sanitize(location: Int, reserveLocation: Int, buffer: [Float]) -> Int {
    return location >= 0 && location < buffer.count
      ? location
      : reserveLocation
  }
}
