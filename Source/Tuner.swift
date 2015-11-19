import Foundation
import AVFoundation
import Pitchy

public protocol TunerDelegate: class {
  func tunerDidRecievePitch(tuner: Tuner, pitch: Pitch)
}

public class Tuner {

  public weak var delegate: TunerDelegate?
  public var active = false

  private let bufferSize: AVAudioFrameCount
  private var frequencies = [Float]()

  private lazy var inputMonitor: InputMonitor = { [unowned self] in
    let inputMonitor = InputMonitor(
      bufferSize: self.bufferSize,
      delegate: self
    )

    return inputMonitor
    }()

  private lazy var frequencyDetector: FrequencyDetector = { [unowned self] in
    let frequencyDetector = FrequencyDetector(delegate: self)
    return frequencyDetector
    }()

  // MARK: - Initialization

  public init(bufferSize: AVAudioFrameCount = 4096, delegate: TunerDelegate?) {
    self.bufferSize = bufferSize
    self.delegate = delegate
  }

  // MARK: - Processing

  public func start() {
    do {
      try inputMonitor.start()
      active = true
    } catch {}
  }

  public func stop() {
    inputMonitor.stop()
    frequencies = [Float]()
    active = false
  }

  // MARK: - Helpers

  private func averageFrequency(frequency: Float) -> Float {
    var result = frequency

    frequencies.insert(frequency, atIndex: 0)

    if frequencies.count > 22 {
      frequencies.removeAtIndex(frequencies.count - 1)
    }

    let count = frequencies.count

    if count > 1 {
      var sortedFrequencies = frequencies.sort { $0 > $1 }

      if count % 2 == 0 {
        let value1 = sortedFrequencies[count / 2 - 1]
        let value2 = sortedFrequencies[count / 2]
        result = (value1 + value2) / 2
      } else {
        result = sortedFrequencies[count / 2]
      }
    }

    return result
  }
}

// MARK: - InputMonitorDelegate

extension Tuner: InputMonitorDelegate {

  public func inputMonitor(inputMonitor: InputMonitor,
    didReceiveBuffer buffer: AVAudioPCMBuffer, atTime time: AVAudioTime) {
      frequencyDetector.readBuffer(buffer, atTime: time)
  }
}

// MARK: - FrequencyDetectorDelegate

extension Tuner: FrequencyDetectorDelegate {

  public func frequencyDetector(frequencyDetector: FrequencyDetector,
    didRetrieveFrequency frequency: Float) {
      let pitch = Pitch(frequency: Double(frequency))
      delegate?.tunerDidRecievePitch(self, pitch: pitch)
  }
}
