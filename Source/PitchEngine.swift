import Foundation
import AVFoundation
import Pitchy

public protocol PitchEngineDelegate: class {
  func pitchEngineDidRecievePitch(pitchEngine: PitchEngine, pitch: Pitch)
  func pitchEngineDidRecieveError(pitchEngine: PitchEngine, error: ErrorType)
}

public class PitchEngine {

  public enum Error: ErrorType {
    case RecordPermissionDenied
  }

  public enum Mode {
    case Record, Play
  }

  public let mode: Mode
  public let bufferSize: AVAudioFrameCount
  public var active = false
  public weak var delegate: PitchEngineDelegate?

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

  public init(mode: Mode, bufferSize: AVAudioFrameCount = 4096, delegate: PitchEngineDelegate?) {
    self.mode = mode
    self.bufferSize = bufferSize
    self.delegate = delegate
  }

  // MARK: - Processing

  public func start() {
    guard mode == .Play else {
      activate()
      return
    }

    AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted  in
      guard let weakSelf = self else { return }

      guard granted else {
        weakSelf.delegate?.pitchEngineDidRecieveError(weakSelf,
          error: Error.RecordPermissionDenied)
        return
      }

      dispatch_async(dispatch_get_main_queue()) {
        weakSelf.activate()
      }
    }
  }

  public func stop() {
    signalTracker.stop()
    active = false
  }

  private func activate() {
    do {
      try signalTracker.start()
      active = true
    } catch {
      delegate?.pitchEngineDidRecieveError(self, error: error)
    }
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
