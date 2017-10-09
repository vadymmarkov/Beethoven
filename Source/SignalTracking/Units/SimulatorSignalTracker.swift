import AVFoundation

/*
 * A mock implemamtation of SignalTracker useful for unit testing and/or running in the simulator.
 *
 * It creates a series of PCM buffers filled with sine waves of given frequencies, 
 * and passes the buffers to the delegate every delayMs milliseconds.
 *
 * Example:
 *
 * #if (arch(i386) || arch(x86_64)) && os(iOS)
 *   // Simulator
 *   let frequencies = try? [
 *     391.995435981749,
 *     391.995435981749,
 *     415.304697579945,
 *     Note(letter: Note.Letter.A, octave: 4).frequency,
 *     466.163761518090,
 *     466.163761518090,
 *     Note(letter: Note.Letter.A, octave: 4).frequency,
 *     415.304697579945,
 *     391.995435981749
 *   ]
 *   let signalTracker = SimulatorSignalTracker(frequencies: frequencies, delayMs: 1000)
 *   let pitchEngine = PitchEngine(config: config, signalTracker: signalTracker, delegate: delegate)
 * #else
 *   // Device
 *   let pitchEngine = PitchEngine(config: config, delegate: delegate)
 * #endif
 *
 */
public final class SimulatorSignalTracker: SignalTracker {
  private static let sampleRate = 8000.0
  private static let sampleCount = 1024

  public var mode: SignalTrackerMode = .record
  public var levelThreshold: Float?
  public var peakLevel: Float?
  public var averageLevel: Float?
  public weak var delegate: SignalTrackerDelegate?

  private let frequencies: [Double]?
  private let delay: Int

  public init(delegate: SignalTrackerDelegate? = nil, frequencies: [Double]? = nil, delayMs: Int = 0) {
    self.delegate = delegate
    self.frequencies = frequencies
    self.delay = delayMs
  }

  public func start() throws {
    guard let frequencies = self.frequencies else { return }

    let time = AVAudioTime(sampleTime: 0, atRate: SimulatorSignalTracker.sampleRate)
    var i = 0

    for frequency in frequencies {
      let buffer = createPCMBuffer(frequency)

      if i == 0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: {
          self.delegate?.signalTracker(self, didReceiveBuffer: buffer, atTime: time)
        })
      } else {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay * i), execute: {
          self.delegate?.signalTracker(self, didReceiveBuffer: buffer, atTime: time)
        })
      }

      i += 1
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay * i), execute: {
      self.delegate?.signalTrackerWentBelowLevelThreshold(self)
    })
  }

  public func stop() {}

  private func createPCMBuffer(_ frequency: Double) -> AVAudioPCMBuffer {
    let format = AVAudioFormat(standardFormatWithSampleRate: SimulatorSignalTracker.sampleRate, channels: 1)
    let buffer = AVAudioPCMBuffer(
      pcmFormat: format!,
      frameCapacity: AVAudioFrameCount(SimulatorSignalTracker.sampleCount)
    )

    if let channelData = buffer?.floatChannelData {
      let velocity = Float32(2.0 * .pi * frequency / SimulatorSignalTracker.sampleRate)

      for i in 0..<SimulatorSignalTracker.sampleCount {
        let sample: Float32 = sin(velocity * Float32(i))
        channelData[0][i] = sample
      }

      buffer?.frameLength = (buffer?.frameCapacity)!
    }

    return buffer!
  }
}
