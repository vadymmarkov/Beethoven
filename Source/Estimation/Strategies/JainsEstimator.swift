import Foundation

public struct JainsEstimator: LocationEstimator {

  public func estimateLocation(buffer: Buffer) throws -> Int {
    let elements = buffer.elements
    let maxIndex = try maxBufferIndex(elements)

    let y2 = abs(elements[maxIndex])
    let y1 = maxIndex == 0 ? y2 : abs(elements[maxIndex - 1])
    let y3 = maxIndex == elements.count - 1 ? y2 : abs(elements[maxIndex + 1])
    let location: Int

    if y1 > y3 {
      let a = y2 / y1
      let d = a / (1 + a)
      location = maxIndex - 1 + Int(round(d))
    } else {
      let a = y3 / y2
      let d = a / (1 + a)
      location = maxIndex + Int(round(d))
    }

    return sanitize(location, reserveLocation: maxIndex, elements: elements)
  }
}
