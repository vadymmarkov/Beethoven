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

class YINUtil {


    class func difference(buffer:[Float]) -> [Float] {

        let frameSize = buffer.count
        let yinBufferSize = frameSize / 2


        // power terms calculation
        //
        var powerTerms = [Float](repeating:0, count:yinBufferSize)

        let addSquare = { (res:Float, element:Float) -> Float in
            res + element * element
        }

        let powerTermFirstElement = buffer.reduce(0.0, addSquare)

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
        var audioTransformedComplex = DSPSplitComplex(realp: &audioRealp, imagp: &audioImagp)

        let temp = UnsafePointer<Float>(buffer)

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

        var kernelRealp = [Float](repeating: 0, count: inputCount)
        var kernelImagp = [Float](repeating: 0, count: inputCount)
        var kernelTransformedComplex = DSPSplitComplex(realp: &kernelRealp, imagp: &kernelImagp)

        let ktemp = UnsafePointer<Float>(kernel)

        ktemp.withMemoryRebound(to: DSPComplex.self, capacity: kernel.count) { (typeConvertedTransferBuffer) -> Void in
            vDSP_ctoz(typeConvertedTransferBuffer, 2, &kernelTransformedComplex, 1, vDSP_Length(inputCount))
        }

        vDSP_fft_zrip(fftSetup!, &kernelTransformedComplex, 1, log2n, FFTDirection(FFT_FORWARD))


        var yinStyleACFRealp = [Float](repeating: 0, count: inputCount)
        var yinStyleACFImagp = [Float](repeating: 0, count: inputCount)
        var yinStyleACFComplex = DSPSplitComplex(realp: &yinStyleACFRealp, imagp: &yinStyleACFImagp)

        for j in 0 ..< inputCount {
            yinStyleACFRealp[j] = audioRealp[j] * kernelRealp[j] - audioImagp[j] * kernelImagp[j];
            yinStyleACFImagp[j] = audioRealp[j] * kernelImagp[j] + audioImagp[j] * kernelRealp[j];
        }

        vDSP_fft_zrip(fftSetup!, &yinStyleACFComplex, 1, log2n, FFTDirection(FFT_INVERSE))


        return yinStyleACFRealp
    }

    class func cumulativeDifference(yinBuffer: inout [Float]) {
        yinBuffer[0] = 1.0

        var runningSum:Float = 0.0

        for tau in 1 ..< yinBuffer.count {
            runningSum += yinBuffer[tau]
            if runningSum == 0 {
                yinBuffer[tau] = 1
            } else {
                yinBuffer[tau] *= Float(tau) / runningSum
            }
        }
    }

    class func absoluteThreshold(yinBuffer:[Float], withThreshold threshold: Float) -> Int {

        var tau = 2
        var minTau = 0
        var minVal:Float = 1000.0

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

    class func parabolicInterpolation(yinBuffer:[Float], tau:Int) -> Float {
        
        guard tau != yinBuffer.count else { return Float(tau) }
        
        var betterTau:Float = 0.0
        
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
        
        return betterTau
    }
    
    class func sumSquare(yinBuffer:[Float], start:Int, end:Int) -> Float {
        var out:Float = 0.0
        
        for i in start ..< end {
            out += yinBuffer[i] * yinBuffer[i]
        }
        
        return out
    }
    
}
