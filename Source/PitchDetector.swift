import Accelerate

public protocol PitchDetectorDelegate: class {
  func pitchDetectorDidUpdateFrequency(pitchDetector: PitchDetector, frequency: Float)
}

public class PitchDetector {

  public struct Defaults {
    static let lowBoundFrequency: Float = 30.0
    static let highBoundFrequency: Float = 4500.0
  }

  public weak var delegate: PitchDetectorDelegate?
  public var highBoundFrequency: Float
  public var lowBoundFrequency: Float
  public var sampleRate: Float

  private var active = false
  private var bufferLength: Int
  private var hanningWindow: UnsafeMutablePointer<Float>
  private var result: UnsafeMutablePointer<Float>
  private var buffer: UnsafeMutablePointer<Int16>
  private var samplesInBuffer: Int

  // MARK: - Initialization

  public init(sampleRate: Float,
    lowBoundFrequency: Float = Defaults.lowBoundFrequency,
    highBoundFrequency: Float = Defaults.highBoundFrequency,
    delegate: PitchDetectorDelegate? = nil) {
      self.sampleRate = sampleRate
      self.lowBoundFrequency = lowBoundFrequency
      self.highBoundFrequency = highBoundFrequency
      self.delegate = delegate

      bufferLength = Int(sampleRate / lowBoundFrequency)
      hanningWindow = UnsafeMutablePointer<Float>.alloc(bufferLength)
      result = UnsafeMutablePointer<Float>.alloc(bufferLength)
      buffer = UnsafeMutablePointer<Int16>.alloc(512)
      samplesInBuffer = 0

      vDSP_hann_window(hanningWindow, vDSP_Length(bufferLength), Int32(vDSP_HANN_NORM))
  }

  // MARK: - Public

  public func addSamples(samples: UnsafeMutablePointer<Int16>, framesCount: Int) {
    var newLength = framesCount
    if samplesInBuffer > 0 {
      newLength += samplesInBuffer
    }

    let newBuffer = UnsafeMutablePointer<Int16>.alloc(newLength)
    memcpy(newBuffer, buffer, samplesInBuffer * sizeof(Int16))
    memcpy(&newBuffer[samplesInBuffer], samples, framesCount * sizeof(Int16))

    free(buffer)
    buffer = newBuffer
    samplesInBuffer = newLength

    if Float(samplesInBuffer) > sampleRate / lowBoundFrequency {
      if !active {
        active = true
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)

        dispatch_async(backgroundQueue) {
          self.correlate(newLength)
        }
      }

      samplesInBuffer = 0
    }
  }

  // MARK: - Private

  private func correlate(framesCount: Int) {
    var frequency: Float = 0
    let samples = buffer
    var returnIndex = 0
    var sum: Float = 0
    var goingUp = false
    var normalize: Float = 0

    for i in 0..<framesCount {
      sum = 0

      for j in 0..<framesCount {
        sum += Float(samples[j] * samples[j + i]) * hanningWindow[j]
      }

      if i == 0 { normalize = sum }
      result[i] = sum / normalize
    }

    for var i in 0..<(framesCount - 8) {
      if result[i] < 0 {
        i += 2
      } else {
        if result[i] > result[i - 1] && !goingUp && i > 1 {
          goingUp = true
        } else if goingUp && result[i] < result[i - 1] {
          if returnIndex == 0 && result[i - 1] > result[0] * 0.95 {
            returnIndex = i - 1
            break
          }
          goingUp = false
        }
      }
    }

    frequency = sampleRate / interpolate(
      y1: result[returnIndex-1],
      y2: result[returnIndex],
      y3: result[returnIndex+1],
      k: returnIndex)

    if frequency >= 27.5 && frequency <= 4500.0 {
      dispatch_async(dispatch_get_main_queue()) {
        self.delegate?.pitchDetectorDidUpdateFrequency(self, frequency: frequency)
      }
    }
    active = false
  }

  private func interpolate(y1 y1: Float, y2: Float, y3: Float, k: Int) -> Float {
    let d = (y3 - y1) / (2 * (2 * y2 - y1 - y3))
    return Float(k) + d
  }
}
