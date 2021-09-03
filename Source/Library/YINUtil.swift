//
//  YINUtil.swift
//  Beethoven
//
//  Created by Guillaume Laurent on 09/10/16.
//  Adapted from https://code.soundsoftware.ac.uk/projects/pyin/repository
//  by Matthias Mauch, Centre for Digital Music, Queen Mary, University of London.
//
//

import UIKit
import Accelerate

final class YINUtil {
  // Slow and eats a lot of CPU, but working
  class func difference2(buffer: [Float]) -> [Float] {
    let bufferHalfCount = buffer.count / 2
    var resultBuffer = [Float](repeating:0.0, count:bufferHalfCount)

    for tau in 0 ..< bufferHalfCount {
      for i in 0 ..< bufferHalfCount {
        let delta = buffer[i] - buffer[i + tau]
        resultBuffer[tau] += delta * delta
      }
    }

    return resultBuffer
  }

  // Accelerated version of difference2 -
  // Instruments shows roughly around 22% CPU usage, compared to 95% for difference2
  class func differenceA(buffer: [Float]) -> [Float] {
    let bufferHalfCount = buffer.count / 2
    var resultBuffer = [Float](repeating:0.0, count:bufferHalfCount)
    var tempBuffer = [Float](repeating:0.0, count:bufferHalfCount)
    var tempBufferSq = [Float](repeating:0.0, count:bufferHalfCount)
    let len = vDSP_Length(bufferHalfCount)
    var vSum: Float = 0.0

    for tau in 0 ..< bufferHalfCount {
        
      let bufferTau = buffer.withUnsafeBufferPointer({ $0 }).baseAddress!.advanced(by: tau)
      // do a diff of buffer with itself at tau offset
      vDSP_vsub(buffer, 1, bufferTau, 1, &tempBuffer, 1, len)
      // square each value of the diff vector
      vDSP_vsq(tempBuffer, 1, &tempBufferSq, 1, len)
      // sum the squared values into vSum
      vDSP_sve(tempBufferSq, 1, &vSum, len)
      // store that in the result buffer
      resultBuffer[tau] = vSum
    }

    return resultBuffer
  }

  // Supposedly faster and less CPU consuming, but doesn't work, must be because I missed something when porting it from
  // https://code.soundsoftware.ac.uk/projects/pyin/repository but I don't know what
  //
  // Kept for reference only.
  // swiftlint:disable function_body_length
  class func difference_broken_do_not_use(buffer: [Float]) -> [Float] {
    let frameSize = buffer.count
    let yinBufferSize = frameSize / 2

    // power terms calculation
    var powerTerms = [Float](repeating:0, count:yinBufferSize)

    _ = { (res: Float, element: Float) -> Float in
      res + element * element
    }

    var powerTermFirstElement: Float = 0.0
    for j in 0 ..< yinBufferSize {
      powerTermFirstElement += buffer[j] * buffer[j]
    }

    powerTerms[0] = powerTermFirstElement

    for tau in 1 ..< yinBufferSize {
      let v = powerTerms[tau - 1]
      let v1 = buffer[tau - 1] * buffer[tau - 1]
      let v2 = buffer[tau + yinBufferSize] * buffer[tau + yinBufferSize]
      let newV = v - v1 + v2

      powerTerms[tau] = newV
    }

    let log2n = UInt(round(log2(Double(buffer.count))))
    let bufferSizePOT = Int(1 << log2n)
    let inputCount = bufferSizePOT / 2
    let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
    var audioRealp = [Float](repeating: 0, count: inputCount)
    var audioImagp = [Float](repeating: 0, count: inputCount)
    var audioTransformedComplex:DSPSplitComplex!
    audioRealp.withUnsafeMutableBufferPointer { realp in
        audioImagp.withUnsafeMutableBufferPointer { imagp in
            audioTransformedComplex = DSPSplitComplex(realp: realp.baseAddress!, imagp: imagp.baseAddress!)
        }
    }
    
    let temp = buffer.withUnsafeBufferPointer({ $0 }).baseAddress!

    temp.withMemoryRebound(to: DSPComplex.self, capacity: buffer.count) { (typeConvertedTransferBuffer) -> Void in
      vDSP_ctoz(typeConvertedTransferBuffer, 2, &audioTransformedComplex, 1, vDSP_Length(inputCount))
    }

    // YIN-STYLE AUTOCORRELATION via FFT
    // 1. data
    vDSP_fft_zrip(fftSetup!, &audioTransformedComplex, 1, log2n, FFTDirection(FFT_FORWARD))

    var kernel = [Float](repeating: 0, count: frameSize)

    // 2. half of the data, disguised as a convolution kernel
    //
    for j in 0 ..< yinBufferSize {
      kernel[j] = buffer[yinBufferSize - 1 - j]
    }
    //        for j in yinBufferSize ..< frameSize {
    //            kernel[j] = 0.0
    //        }

    var kernelRealp = [Float](repeating: 0, count: frameSize)
    var kernelImagp = [Float](repeating: 0, count: frameSize)
    var kernelTransformedComplex:DSPSplitComplex!
    kernelRealp.withUnsafeMutableBufferPointer { realp in
        kernelImagp.withUnsafeMutableBufferPointer { imagp in
            kernelTransformedComplex = DSPSplitComplex(realp: realp.baseAddress!, imagp: imagp.baseAddress!)
          }
      }
    
    let ktemp = kernel.withUnsafeBufferPointer({ $0 }).baseAddress!

    ktemp.withMemoryRebound(to: DSPComplex.self, capacity: kernel.count) { (typeConvertedTransferBuffer) -> Void in
      vDSP_ctoz(typeConvertedTransferBuffer, 2, &kernelTransformedComplex, 1, vDSP_Length(inputCount))
    }

    vDSP_fft_zrip(fftSetup!, &kernelTransformedComplex, 1, log2n, FFTDirection(FFT_FORWARD))

    var yinStyleACFRealp = [Float](repeating: 0, count: frameSize)
    var yinStyleACFImagp = [Float](repeating: 0, count: frameSize)
    var yinStyleACFComplex:DSPSplitComplex!
    yinStyleACFRealp.withUnsafeMutableBufferPointer { realp in
        yinStyleACFImagp.withUnsafeMutableBufferPointer { imagp in
            yinStyleACFComplex = DSPSplitComplex(realp: realp.baseAddress!, imagp: imagp.baseAddress!)
          }
      }
    

    for j in 0 ..< inputCount {
      yinStyleACFRealp[j] = audioRealp[j] * kernelRealp[j] - audioImagp[j] * kernelImagp[j]
      yinStyleACFImagp[j] = audioRealp[j] * kernelImagp[j] + audioImagp[j] * kernelRealp[j]
    }

    vDSP_fft_zrip(fftSetup!, &yinStyleACFComplex, 1, log2n, FFTDirection(FFT_INVERSE))

    var resultYinBuffer = [Float](repeating:0.0, count: yinBufferSize)

    for j in 0 ..< yinBufferSize {
      resultYinBuffer[j] = powerTerms[0] + powerTerms[j] - 2 * yinStyleACFRealp[j + yinBufferSize - 1]
    }

    return resultYinBuffer
  }

  class func cumulativeDifference(yinBuffer: inout [Float]) {
    yinBuffer[0] = 1.0

    var runningSum: Float = 0.0

    for tau in 1 ..< yinBuffer.count {
      runningSum += yinBuffer[tau]

      if runningSum == 0 {
        yinBuffer[tau] = 1
      } else {
        yinBuffer[tau] *= Float(tau) / runningSum
      }
    }
  }

  class func absoluteThreshold(yinBuffer: [Float], withThreshold threshold: Float) -> Int {
    var tau = 2
    var minTau = 0
    var minVal: Float = 1000.0

    while tau < yinBuffer.count {
      if yinBuffer[tau] < threshold {
        while (tau + 1) < yinBuffer.count && yinBuffer[tau + 1] < yinBuffer[tau] {
          tau += 1
        }
        return tau
      } else {
        if yinBuffer[tau] < minVal {
          minVal = yinBuffer[tau]
          minTau = tau
        }
      }
      tau += 1
    }

    if minTau > 0 {
      return -minTau
    }

    return 0
  }

  class func parabolicInterpolation(yinBuffer: [Float], tau: Int) -> Float {
    guard tau != yinBuffer.count else {
      return Float(tau)
    }

    var betterTau: Float = 0.0

    if tau > 0  && tau < yinBuffer.count - 1 {
      let s0 = yinBuffer[tau - 1]
      let s1 = yinBuffer[tau]
      let s2 = yinBuffer[tau + 1]

      var adjustment = (s2 - s0) / (2.0 * (2.0 * s1 - s2 - s0))

      if abs(adjustment) > 1 {
        adjustment = 0
      }

      betterTau = Float(tau) + adjustment
    } else {
      betterTau = Float(tau)
    }

    return abs(betterTau)
  }

  class func sumSquare(yinBuffer: [Float], start: Int, end: Int) -> Float {
    var out: Float = 0.0

    for i in start ..< end {
      out += yinBuffer[i] * yinBuffer[i]
    }

    return out
  }
}
