import Foundation
import AVFoundation
import Pitchy

public protocol PitchEngineDelegate: class {
  func pitchEngineDidRecievePitch(pitchEngine: PitchEngine, pitch: Pitch)
  func pitchEngineDidRecieveError(pitchEngine: PitchEngine, error: ErrorType)
}

public class PitchEngine {

  public weak var delegate: PitchEngineDelegate?
  public var active = false

  private let bufferSize: AVAudioFrameCount
  private var frequencies = [Float]()
  public var pitches = [Pitch]()
  public var currentPitch: Pitch!

  private lazy var signalTracker: SignalTrackingAware = { [unowned self] in
    let inputMonitor = InputSignalTracker(
      bufferSize: self.bufferSize,
      delegate: self
    )

    return inputMonitor
    }()

  private var transformer: TransformAware = FFTTransformer()
  private var estimator: EstimationAware = HPSEstimator()

  // MARK: - Initialization

  public init(bufferSize: AVAudioFrameCount = 4096, delegate: PitchEngineDelegate?) {
    self.bufferSize = bufferSize
    self.delegate = delegate
  }

  // MARK: - Processing

  public func start() {
    do {
      try signalTracker.start()
      active = true
    } catch {}
  }

  public func stop() {
    signalTracker.stop()
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

// MARK: - SignalTrackingDelegate

extension PitchEngine: SignalTrackingDelegate {

  public func signalTracker(signalTracker: SignalTrackingAware,
    didReceiveBuffer buffer: AVAudioPCMBuffer, atTime time: AVAudioTime) {
      let transformedBuffer = transformer.transformBuffer(buffer)
      do {
        let frequency = try estimator.estimateFrequency(Float(time.sampleRate),
          buffer: transformedBuffer)
        let pitch = Pitch(frequency: Double(frequency))
        delegate?.pitchEngineDidRecievePitch(self, pitch: pitch)
      } catch {
        delegate?.pitchEngineDidRecieveError(self, error: error)
      }
  }
}
