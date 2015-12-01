import Foundation

public class QuinnsSecondEstimator: EstimationAware {

  public func estimateLocation(transformResult: TransformResult, sampleRate: Float) -> Int {
    let buffer = transformResult.buffer

    guard let maxElement = buffer.maxElement(),
      k = buffer.indexOf(maxElement) else {
        return 0
    }

    guard let complexBuffer = transformResult.complexBuffer else {
      return k
    }

    let realp = complexBuffer.realp
    let imagp = complexBuffer.imagp

    let ap1 = realp[k + 1] * realp[k] + imagp[k+1] * imagp[k]
    let ap2 = realp[k] * realp[k] + imagp[k] * imagp[k]

    let ap = ap1 / ap2
    let dp = -ap / (1 - ap)

    let am1 = realp[k - 1] * realp[k] + imagp[k - 1] * imagp[k]
    let am2 = realp[k] * realp[k] + imagp[k] * imagp[k]

    let am = am1  / am2
    let dm = am / (1 - am)
    let d = (dp + dm) / 2 + tau(dp * dp) - tau(dm * dm)
    let r = k + Int(round(d))

    return r
  }

  private func tau(x: Float) -> Float {
    let p1 = log(3 * x * x + 6 * x + 1)
    let p2 = x + 1 - sqrt(2/3)
    let p3 = log(p2) /  (x + 1 + sqrt(2/3))
    return 1/4 * p1 - sqrt(6)/24 * p3
  }
}
