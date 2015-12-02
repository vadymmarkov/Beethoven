import AVFoundation
import Accelerate

public class FFTTransformer: TransformAware {

  public func transformBuffer(buffer: AVAudioPCMBuffer) -> Buffer {
    let frameCount = buffer.frameCapacity
    let log2n = UInt(round(log2(Double(frameCount))))
    let bufferSizePOT = Int(1 << log2n)
    let inputCount = bufferSizePOT / 2
    let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))

    var realp = [Float](count: inputCount, repeatedValue: 0)
    var imagp = [Float](count: inputCount, repeatedValue: 0)
    var output = DSPSplitComplex(realp: &realp, imagp: &imagp)

    // TODO: Improve this
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

    return Buffer(elements: normalizedMagnitudes, complexElements: output)
  }

  // MARK: - Helpers

  func sqrtq(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvsqrtf(&results, x, [Int32(x.count)])

    return results
  }
}
