import Foundation

enum EstimationError: ErrorType {
  case EmptyBuffer
  case UnknownMaxIndex
}

protocol EstimationAware {

  func estimateLocation(transformResult: TransformResult, sampleRate: Float) throws -> Int
}

extension EstimationAware {

  func maxBufferIndex(buffer: [Float]) throws -> Int {
    guard buffer.count > 0 else {
      throw EstimationError.EmptyBuffer
    }

    guard let index = buffer.maxIndex else {
      throw EstimationError.UnknownMaxIndex
    }

    return index
  }

  func sanitize(location: Int, reserveLocation: Int, buffer: [Float]) -> Int {
    return location >= 0 && location < buffer.count
      ? location
      : reserveLocation
  }
}
