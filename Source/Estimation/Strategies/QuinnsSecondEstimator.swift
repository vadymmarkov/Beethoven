import Foundation

final class QuinnsSecondEstimator: LocationEstimator {
  func estimateLocation(buffer: Buffer) throws -> Int {
    let elements = buffer.elements
    let maxIndex = try maxBufferIndex(from: elements)

    guard let realElements = buffer.realElements, let imagElements = buffer.imagElements else {
      return maxIndex
    }

    let realp = realElements
    let imagp = imagElements

    let prevIndex = maxIndex == 0 ? maxIndex : maxIndex - 1
    let nextIndex = maxIndex == buffer.count - 1 ? maxIndex : maxIndex + 1
    let divider = pow(realp[maxIndex], 2.0) + pow(imagp[maxIndex], 2.0)

    let ap = (realp[nextIndex] * realp[maxIndex] + imagp[nextIndex] * imagp[maxIndex]) / divider
    let dp = -ap  / (1.0 - ap)
    let am = (realp[prevIndex] * realp[maxIndex] + imagp[prevIndex] * imagp[maxIndex]) / divider
    let dm = am / (1.0 - am)
    let d = (dp + dm) / 2 + tau(dp * dp) - tau(dm * dm)
    let location = maxIndex + Int(round(d))

    return sanitize(location: location, reserveLocation: maxIndex, elements: elements)
  }

  private func tau(_ x: Float) -> Float {
    let p1 = log(3 * pow(x, 2.0) + 6 * x + 1)
    let part1 = x + 1 - sqrt(2/3)
    let part2 = x + 1 + sqrt(2/3)
    let p2 = log(part1 / part2)

    return 1/4 * p1 - sqrt(6)/24 * p2
  }
}
