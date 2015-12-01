import Foundation

public class QuinnsFirstEstimator: EstimationAware {

  public func estimateLocation(transformResult: TransformResult, sampleRate: Float) -> Int {
    let buffer = transformResult.buffer

    guard let maxElement = buffer.maxElement(),
      maxIndex = buffer.indexOf(maxElement) else {
        return 0
    }

    guard let complexBuffer = transformResult.complexBuffer else {
      return maxIndex
    }

    let realp = complexBuffer.realp
    let imagp = complexBuffer.imagp

    let prevIndex = maxIndex == 0 ? maxIndex : maxIndex - 1
    let nextIndex = maxIndex == buffer.count - 1 ? maxIndex : maxIndex + 1
    let divider = pow(realp[maxIndex], 2.0) + pow(imagp[maxIndex], 2.0)

    let ap = (realp[nextIndex] * realp[maxIndex] + imagp[nextIndex] * imagp[maxIndex]) / divider
    let dp = -ap  / (1.0 - ap)
    let am = (realp[prevIndex] * realp[maxIndex] + imagp[prevIndex] * imagp[maxIndex]) / divider
    let dm = am / (1.0 - am)
    let d = dp > 0 && dm > 0 ? dp : dm
    let location = maxIndex + Int(round(d))

    return location >= 0 && location < buffer.count
      ? location
      : maxIndex
  }
}


/*
let y1 = abs(normalizedMagnitudes[k-1])
let y2 = abs(normalizedMagnitudes[k])
let y3 = abs(normalizedMagnitudes[k+1])
if y1 > y3 {
let a = y2  /  y1
let d = a  /  (1 + a)
r = k - 1 + Int(round(d))
} else {
let a = y3  /  y2
let d = a  /  (1 + a)
r = k + Int(round(d))
}
//let r  =  k + Int(d)*/


