import Foundation

public struct BarycentricEstimator: LocationEstimator {

  public func estimateLocation(buffer: Buffer) throws -> Int {
    let elements = buffer.elements
    let maxIndex = try maxBufferIndex(elements)

    let y2 = abs(elements[maxIndex])
    let y1 = maxIndex == 0 ? y2 : abs(elements[maxIndex - 1])
    let y3 = maxIndex == elements.count - 1 ? y2 : abs(elements[maxIndex + 1])
    let d = (y3 - y1) / (y1 + y2 + y3)

    guard !d.isNaN else {
      throw EstimationError.UnknownLocation
    }

    let location = maxIndex + Int(round(d))

    return sanitize(location, reserveLocation: maxIndex, elements: elements)
  }
}
