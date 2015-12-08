import Foundation

public class MPMEstimator: EstimationAware {

  public struct Defaults {
    static let bufferSize = 1024
    static let overlap = 768
    static let cutoff: Float = 0.97
    static let smallCutoff: Float = 0.5
    static let lowerPitchCutoff: Float = 80.0
  }

  let cutoff: Float
  var nsdf: [Float]
  var turningPointX: Float = 0.0
  var turningPointY: Float = 0.0
  var maxPositions = [Int]()
  var periodEstimates = [Float]()
  var ampEstimates = [Float]()

  // MARK: - Initialization

  public init(bufferSize: Int = Defaults.bufferSize, cutoff: Float = Defaults.cutoff) {
    self.cutoff = cutoff

    nsdf = [Float](count: bufferSize, repeatedValue: 0)
  }

  public func estimateFrequency(sampleRate: Float, buffer: Buffer) throws -> Float {
    let elements = buffer.elements
    var frequency: Float?

    maxPositions = []
    periodEstimates = []
    ampEstimates = []

    normalizedSquareDifference(elements)
    peakPicking()

    var highestAmplitude = -Float.infinity

    for tau in maxPositions {
      highestAmplitude = max(highestAmplitude, nsdf[tau])

      if nsdf[tau] > Defaults.smallCutoff {
        parabolicInterpolation(tau)
        ampEstimates.append(turningPointY)
        periodEstimates.append(turningPointX)
        highestAmplitude = max(highestAmplitude, turningPointY)
      }
    }

    if !periodEstimates.isEmpty {
      let actualCutoff = cutoff * highestAmplitude;
      var periodIndex = 0

      for var i = 0; i < ampEstimates.count; i++ {
        if ampEstimates[i] >= actualCutoff {
          periodIndex = i
          break
        }
      }

      let period = periodEstimates[periodIndex]
      let pitchEstimate = sampleRate / period

      if pitchEstimate > Defaults.lowerPitchCutoff {
        frequency = pitchEstimate
      }
    }

    guard let estimatedFrequency = frequency else {
      throw EstimationError.UnknownFrequency
    }

    return estimatedFrequency
  }

  // MARK: - Helpers

  private func normalizedSquareDifference(audioBuffer: [Float]) {
		for var tau = 0; tau < audioBuffer.count; tau++ {
      var acf: Float = 0.0
      var divisorM: Float = 0.0

      for var i = 0; i < audioBuffer.count - tau; i++ {
        acf += audioBuffer[i] * audioBuffer[i + tau]
        divisorM += audioBuffer[i] * audioBuffer[i]
          + audioBuffer[i + tau] * audioBuffer[i + tau]
      }

      nsdf[tau] = 2 * acf / divisorM;
		}
  }

  private func parabolicInterpolation(tau: Int) {
		let nsdfa = nsdf[tau - 1]
		let nsdfb = nsdf[tau]
		let nsdfc = nsdf[tau + 1]
		let bValue = Float(tau)
		let bottom = nsdfc + nsdfa - 2.0 * nsdfb

    if bottom == 0.0 {
      turningPointX = bValue
      turningPointY = nsdfb
		} else {
      let delta = nsdfa - nsdfc
      turningPointX = bValue + delta / (2 * bottom)
      turningPointY = nsdfb - delta * delta / (8 * bottom)
		}
  }

  private func peakPicking() {
    var pos = 0
    var curMaxPos = 0

    while pos < (nsdf.count - 1) / 3 && nsdf[pos] > 0 {
      pos++
    }

    while pos < nsdf.count - 1 && nsdf[pos] <= 0.0 {
      pos++
    }

    if pos == 0 {
      pos = 1
    }

    while pos < nsdf.count - 1 {
      guard nsdf[pos] >= 0 else { continue }

      if nsdf[pos] > nsdf[pos - 1] && nsdf[pos] >= nsdf[pos + 1] {
        if curMaxPos == 0 {
          curMaxPos = pos
        } else if nsdf[pos] > nsdf[curMaxPos] {
          curMaxPos = pos
        }
      }

      pos++

      if pos < nsdf.count - 1 && nsdf[pos] <= 0 {
        if curMaxPos > 0 {
          maxPositions.append(curMaxPos)
          curMaxPos = 0
        }

        while pos < nsdf.count - 1 && nsdf[pos] <= 0.0 {
          pos++
        }
      }
    }

    if curMaxPos > 0 {
      maxPositions.append(curMaxPos)
    }
  }
}
