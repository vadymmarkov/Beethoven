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


  public var pitches = [Pitch]()
  public var currentPitch: Pitch!

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

  private func averagePitch(pitch: Pitch) -> Pitch {
    if let first = pitches.first where first.note.letter != pitch.note.letter {
      pitches = []
    }
    pitches.append(pitch)

    if pitches.count == 1 {
      currentPitch = pitch
      return currentPitch
    }

    let pts1 = pitches.filter({ $0.note.index == pitch.note.index }).count
    let pts2 = pitches.filter({ $0.note.index == currentPitch.note.index }).count

    currentPitch = pts1 >= pts2 ? pitch : pitches[pitches.count - 1]

    return currentPitch
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
