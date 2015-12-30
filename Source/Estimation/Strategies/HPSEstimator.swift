public struct HPSEstimator: LocationEstimator {

  public var harmonics = 5
  public var minIndex = 20

  public func estimateLocation(buffer: Buffer) throws -> Int {
    var spectrum = buffer.elements
    let maxIndex = spectrum.count - 1
    var maxHIndex = spectrum.count / harmonics

    if maxIndex < maxHIndex {
      maxHIndex = maxIndex
    }

    var location = minIndex

    for var j = minIndex; j <= maxHIndex; j++ {
      for var i = 1; i <= harmonics; i++ {
        spectrum[j] *= spectrum[j * i]
      }

      if spectrum[j] > spectrum[location] {
        location = j
      }
    }

    var max2 = minIndex
    let maxsearch = location * 3 / 4

    for var i = minIndex + 1; i < maxsearch; i++ {
      if spectrum[i] > spectrum[max2] {
        max2 = i
      }
    }

    if abs(max2 * 2 - location) < 4 {
      if spectrum[max2] / spectrum[location] > 0.2 {
        location = max2
      }
    }

    return sanitize(location, reserveLocation: maxIndex, elements: spectrum)
  }
}
