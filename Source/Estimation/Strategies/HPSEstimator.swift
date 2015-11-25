import Foundation

public class HPSEstimator: EstimationAware {

  public var harmonics = 5
  public var minIndex = 20

  public func estimateLocation(transformResult: TransformResult, sampleRate: Float) -> Int {
    var spectrum = transformResult.buffer
    let maxIndex = spectrum.count - 1
    var i: Int, j: Int
    var maxHIndex = spectrum.count / harmonics

    if maxIndex < maxHIndex {
      maxHIndex = maxIndex
    }

    var maxLocation = minIndex

    for j = minIndex; j <= maxHIndex; j++ {
      for i = 1; i <= harmonics; i++ {
        spectrum[j] *= spectrum[j * i]
      }

      if spectrum[j] > spectrum[maxLocation] {
        maxLocation = j
      }
    }

    var max2 = minIndex
    let maxsearch = maxLocation * 3 / 4

    for i = minIndex + 1; i < maxsearch; i++ {
      if spectrum[i] > spectrum[max2] {
        max2 = i
      }
    }

    if abs(max2 * 2 - maxLocation) < 4 {
      if spectrum[max2] / spectrum[maxLocation] > 0.2 {
        maxLocation = max2
      }
    }

    return maxLocation
  }
}
