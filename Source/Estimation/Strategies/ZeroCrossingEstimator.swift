import Foundation

public struct ZeroCrossingEstimator: EstimationAware {

  public func estimateLocation(buffer: Buffer) throws -> Int {
    let elements = buffer.elements
    let maxIndex = try maxBufferIndex(elements)

    var location = 0
    let size = elements.count

    for var i = 0; i < size - 1; i++ {
      if (elements[i] >= 0 && elements[i + 1] < 0) || (elements[i] < 0 && elements[i + 1] >= 0) {
        location++;
      }
    }

    return sanitize(location, reserveLocation: maxIndex, elements: elements)
  }
}

