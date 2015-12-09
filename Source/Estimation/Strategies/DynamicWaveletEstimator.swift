import Foundation

public class DynamicWaveletEstimator: Estimator {

  public struct Defaults {
    static let maxFLWTlevels = 6;
    static let maxF = 3000.0
    static let differenceLevelsN = 3
    static let maximaThresholdRatio = 0.75;
  }

  var distances = [Int]()
  var mins = [Int]()
  var maxs = [Int]()

  public func estimateFrequency(sampleRate: Float, buffer: Buffer) throws -> Float {
    var audioBuffer = buffer.elements

    var pitchF: Float?
    var curSamNb = audioBuffer.count
    var nbMins = 0
    var nbMaxs = 0

    distances = [Int](count: audioBuffer.count, repeatedValue: 0)
    mins = [Int](count: audioBuffer.count, repeatedValue: 0)
    maxs = [Int](count: audioBuffer.count, repeatedValue: 0)

    var ampltitudeThreshold = 0.0
    var theDC = 0.0

    var maxValue = 0.0
    var minValue = 0.0

    for var i = 0; i < audioBuffer.count; i++ {
      let sample = Double(audioBuffer[i])
      theDC = theDC + sample
      maxValue = max(maxValue, sample)
      minValue = min(sample, minValue)
    }

    theDC = theDC / Double(audioBuffer.count)
    maxValue = maxValue - theDC
    minValue = minValue - theDC
    let amplitudeMax = maxValue > -minValue ? maxValue : -minValue

    ampltitudeThreshold = amplitudeMax * Defaults.maximaThresholdRatio;

    var curLevel = 0
    var curModeDistance = -1.0
    var delta: Int

    search: while(true) {
      delta = Int(Double(sampleRate) / (pow(2.0, Double(curLevel)) * Double(Defaults.maxF)))
      if curSamNb < 2 {
        break search
      }

      var dv: Double
      var previousDV: Double = -1000

      nbMins = 0
      nbMaxs = 0
      var lastMinIndex = -1000000
      var lastmaxIndex = -1000000
      var findMax = false
      var findMin = false

      for var i = 2; i < curSamNb; i++ {
        let si = Double(audioBuffer[i]) - theDC
        let si1 = Double(audioBuffer[i-1]) - theDC

        if si1 <= 0 && si > 0 { findMax = true }
        if si1 >= 0 && si < 0 { findMin = true }

        dv = si - si1

        if previousDV > -1000 {
          if findMin && previousDV < 0 && dv >= 0 {
            if abs(si) >= ampltitudeThreshold {
              if i > lastMinIndex + delta {
                mins[nbMins++] = i
                lastMinIndex = i
                findMin = false
              }
            }
          }

          if findMax  && previousDV > 0 && dv <= 0 {
            if abs(si) >= ampltitudeThreshold {
              if i > lastmaxIndex + delta {
                maxs[nbMaxs++] = i
                lastmaxIndex = i
                findMax = false
              }
            }
          }
        }

        previousDV = dv
      }

      if nbMins == 0 && nbMaxs == 0 {
        break search
      }

      var d: Int
      distances = [Int](count: audioBuffer.count, repeatedValue: 0)

      for var i = 0 ; i < nbMins ; i++ {
        for var j = 1; j < Defaults.differenceLevelsN; j++ {
          if i + j < nbMins {
            d = abs(mins[i] - mins[i+j])
            distances[d] = distances[d] + 1
          }
        }
      }

      var bestDistance = -1
      var bestValue = -1

      for var i = 0; i < curSamNb; i++ {
        var summed = 0

        for var j = -delta ; j <= delta ; j++ {
          if i + j >= 0 && i + j < curSamNb {
            summed += distances[i+j]
          }
        }

        if summed == bestValue {
          if i == 2 * bestDistance {
            bestDistance = i
          }
        } else if summed > bestValue {
          bestValue = summed
          bestDistance = i
        }
      }

      var distAvg = 0.0
      var nbDists = 0.0;

      for var j = -delta ; j <= delta; j++ {
        if bestDistance + j >= 0 && bestDistance + j < audioBuffer.count {
          let nbDist = distances[bestDistance + j]
          if nbDist > 0 {
            nbDists += Double(nbDist)
            distAvg += Double((bestDistance + j) * nbDist)
          }
        }
      }

      distAvg /= nbDists

      if curModeDistance > -1.0 {
        let similarity = abs(distAvg * 2 - curModeDistance)
        print(similarity)
        if similarity <= 2.0 * Double(delta) {
          pitchF = Float((Double(sampleRate) / (pow(2.0 , Double(curLevel - 1)) * curModeDistance)))
          break search
        }
      }

      curModeDistance = distAvg


      curLevel = curLevel + 1
      if curLevel >= Defaults.maxFLWTlevels {
        break search
      }

      if curSamNb < 2 {
        break search
      }

      var newAudioBuffer = audioBuffer

      if curSamNb == distances.count {
        newAudioBuffer = [Float](count: curSamNb/2, repeatedValue: 0)
      }

      for var i = 0; i < curSamNb / 2; i++ {
        newAudioBuffer[i] = (audioBuffer[2 * i] + audioBuffer[2 * i + 1]) / 2.0
      }
      audioBuffer = newAudioBuffer
      curSamNb /= 2
    }

    guard let estimatedFrequency = pitchF else {
      throw EstimationError.UnknownFrequency
    }

    return estimatedFrequency
  }

  // MARK: - Helpers
}
