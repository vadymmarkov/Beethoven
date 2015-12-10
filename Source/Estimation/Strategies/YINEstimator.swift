import Foundation

public class YINEstimator: Estimator {

  struct Defaults {
    static let minFrequency = 82.0
    static let maxFrequency = 1000.0
    static let ratio = 5.0
    static let sensivity = 0.1
  }

  var amd: [Double] = [Double]()
  var ratio: Double = Defaults.ratio
  var sensitivity: Double = Defaults.sensivity
  let minFrequency = Defaults.minFrequency
  let maxFrequency = Defaults.maxFrequency

  public func estimateFrequency(sampleRate: Float, buffer: Buffer) throws -> Float {
    let audioBuffer = buffer.elements
    let maxPeriod = round(Double(sampleRate) / minFrequency + 0.5)
    let minPeriod = round(Double(sampleRate) / maxFrequency + 0.5)

    if amd.isEmpty {
      amd = [Double](count: audioBuffer.count / 2, repeatedValue: 0)
    }

    var t = 0
    var f0: Float?
    var minval = Double.infinity
    var maxval = -Double.infinity
    var frames1 = [Double]()
    var frames2 = [Double]()
    var calcSub = [Double]()

    let maxShift = audioBuffer.count / 2

    for var i = 0; i < maxShift; i++ {
      frames1 = [Double](count: maxShift - i + 1, repeatedValue: 0)
      frames2 = [Double](count: maxShift - i + 1, repeatedValue: 0)
      t = 0

      for var aux1 = 0; aux1 < maxShift - i; aux1++ {
        t = t + 1
        frames1[t] = Double(audioBuffer[aux1])
      }

      t = 0

      for var aux2 = i; aux2 < maxShift; aux2++ {
        t = t + 1
        frames2[t] = Double(audioBuffer[aux2])
      }

      let frameLength = frames1.count
      calcSub = [Double](count: frameLength, repeatedValue: 0)

      for var u = 0; u < frameLength; u++ {
        calcSub[u] = frames1[u] - frames2[u];
      }

      var summation = 0.0
      for var l = 0; l < frameLength; l++ {
        summation += abs(calcSub[l])
      }

      amd[i] = summation
    }

    for var j = Int(minPeriod); j < Int(maxPeriod); j++ {
      if amd[j] < minval {
        minval = amd[j]
      }

      if amd[j] > maxval	{
        maxval = amd[j]
      }
    }

    let cutoff = Int(round((sensitivity * (maxval - minval)) + minval))
    var j = Int(minPeriod)

    while (j <= Int(maxPeriod) && (amd[j] > Double(cutoff))) {
      j = j + 1
    }

    let search_length: Double = minPeriod / 2
    minval = amd[j]
    var minpos = j
    var i = j
    while ((Double(i) < Double(j) + search_length) && (Double(i) <= maxPeriod)){
      i = i + 1
      if amd[i] < minval {
        minval = amd[i]
        minpos = i
      }
    }

    if round(amd[minpos] * ratio) < maxval {
      f0 = sampleRate / Float(minpos)
    }

    guard let estimatedFrequency = f0 else {
      throw EstimationError.UnknownFrequency
    }

    print(estimatedFrequency)

    return estimatedFrequency
  }
}
