import Accelerate
import AVFoundation
import Foundation

public protocol FrequencyDetectorDelegate: class {

  func frequencyDetector(frequencyDetector: FrequencyDetector,
    didRetrieveFrequency frequency: Float)
}

public class FrequencyDetector {

  public weak var delegate: FrequencyDetectorDelegate?

  // MARK: - Initialization

  public init(delegate: FrequencyDetectorDelegate? = nil) {
    self.delegate = delegate
  }

  // MARK: - Reading

  public func readBuffer(buffer: AVAudioPCMBuffer, atTime time: AVAudioTime) {
    let frameCount = buffer.frameCapacity
    let log2n = UInt(round(log2(Double(frameCount))))
    let bufferSizePOT = Int(1 << log2n)
    let inputCount = bufferSizePOT / 2
    let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))


    var realp = [Float](count: inputCount, repeatedValue: 0)
    var imagp = [Float](count: inputCount, repeatedValue: 0)
    var output = DSPSplitComplex(realp: &realp, imagp: &imagp)

    vDSP_hann_window(&realp, vDSP_Length(inputCount), Int32(vDSP_HANN_NORM))

    vDSP_ctoz(UnsafePointer<DSPComplex>(buffer.floatChannelData.memory), 2,
      &output, 1, vDSP_Length(inputCount))
    vDSP_fft_zrip(fftSetup, &output, 1, log2n, FFTDirection(FFT_FORWARD))

    var magnitudes = [Float](count:inputCount, repeatedValue:0.0)
    vDSP_zvmags(&output, 1, &magnitudes, 1, vDSP_Length(inputCount))

    var normalizedMagnitudes = [Float](count: inputCount, repeatedValue: 0.0)
    vDSP_vsmul(sqrtq(magnitudes), 1, [2.0 / Float(inputCount)],
      &normalizedMagnitudes, 1, vDSP_Length(inputCount))



    vDSP_destroy_fftsetup(fftSetup)

    let st = Spectrum(samples: normalizedMagnitudes, sampleRateInHz: Float(time.sampleRate))
    let frequency = st.getFrequency(Float(bufferSizePOT))
    delegate?.frequencyDetector(self, didRetrieveFrequency: frequency)

    return

    if let maxMagnitude = magnitudes.maxElement(),
      k = magnitudes.indexOf(maxMagnitude) {

        var r: Int
        let X = output

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
        //let r  =  k + Int(d)

        print("k : '\(k), r: '\(r)'")
    */
        let ap1 = realp[k + 1] * realp[k] + imagp[k+1] * imagp[k]
        let ap2 = realp[k] * realp[k] + imagp[k] * imagp[k]

        let ap = ap1 / ap2
        let dp = -ap / (1 - ap)

        let am1 = realp[k - 1] * realp[k] + imagp[k - 1] * imagp[k]
        let am2 = realp[k] * realp[k] + imagp[k] * imagp[k]

        let am = am1  / am2
        let dm = am / (1 - am)
        let d = (dp + dm) / 2 + tau(dp * dp) - tau(dm * dm)
        r = k + Int(round(d))

        print("\(k) - \(d) \(Int(round(d))) - \(r)")

        let frequency = Float(r) * Float(time.sampleRate) / Float(bufferSizePOT)
        delegate?.frequencyDetector(self, didRetrieveFrequency: frequency)
    }
  }

  // MARK: - Helpers

  private func tau(x: Float) -> Float {
    let p1 = log(3 * x * x + 6 * x + 1)
    let p2 = x + 1 - sqrt(2/3)
    let p3 = log(p2) /  (x + 1 + sqrt(2/3))
    return 1/4 * p1 - sqrt(6)/24 * p3
  }

  private func sqrtq(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvsqrtf(&results, x, [Int32(x.count)])

    return results
  }
}

class Spectrum {

  var spectrum: [Float]
  //var samples: [Float]
  var sampleRate: Float

  init(samples: [Float], sampleRateInHz: Float) {
    self.sampleRate = sampleRateInHz;
    self.spectrum = samples
  }

  func getFrequency(bufferSizePOT: Float) -> Float {
    let harmonics = 5
    let minIndex = 20, maxIndex = spectrum.count - 1

    // set the maximum index to search for a pitch
    var i: Int, j: Int
    var maxHIndex = spectrum.count/harmonics
    if (maxIndex < maxHIndex) {
      maxHIndex = maxIndex
    }

    // generate the Harmonic Product Spectrum values and keep track of the
    // maximum amplitude value to assign to a pitch.

    var maxLocation = minIndex;
    for (j=minIndex; j<=maxHIndex; j++) {
      for (i=1; i<=harmonics; i++) {  // i=1: double the fundamental
        spectrum[j] *= spectrum[j*i];
      }
      if (spectrum[j] > spectrum[maxLocation]) {
        maxLocation = j;
      }
    }

    // Correct for octave too high errors.  If the maximum subharmonic
    // of the measured maximum is approximately 1/2 of the maximum
    // measured frequency, AND if the ratio of the sub-harmonic
    // to the total maximum is greater than 0.2, THEN the pitch value
    // is assigned to the subharmonic.

    var max2 = minIndex;
    var maxsearch = maxLocation * 3 / 4;
    for (i=minIndex+1; i<maxsearch; i++) {
      if (spectrum[i] > spectrum[max2]) {
        max2 = i;
      }
    }
    if (abs(max2 * 2 - maxLocation) < 4) {
      if (spectrum[max2]/spectrum[maxLocation] > 0.2) {
        maxLocation = max2;
      }
    }


    //if largest > average * 5 {
    let freqFraction = Float(maxLocation) / Float(bufferSizePOT)
    let frequency = sampleRate * freqFraction
    //}

    //let frequency = Float(r) * Float(time.sampleRate) / Float(bufferSizePOT)

    return frequency
  }

  private func quadraticPeak(index: Int) -> Float {
    let alpha = spectrum[index-1]
    let beta = spectrum[index]
    let gamma = spectrum[index+1]
    let p = 0.5 * ((alpha - gamma) / (alpha - 2 * beta + gamma))
    let k = Float(index) + p
    
    return k
  }
}

