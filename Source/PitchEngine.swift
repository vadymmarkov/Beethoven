import UIKit
import AVFoundation
import Pitchy

public protocol PitchEngineDelegate: class {
  func pitchEngineDidReceivePitch(_ pitchEngine: PitchEngine, pitch: Pitch)
  func pitchEngineDidReceiveError(_ pitchEngine: PitchEngine, error: Error)
  func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine)
}

public enum PitchEngineError: Error {
  case recordPermissionDenied
}

public class PitchEngine {

  public enum Mode {
    case record, playback
  }

  public let bufferSize: AVAudioFrameCount
  public var active = false
  public weak var delegate: PitchEngineDelegate?

  fileprivate var estimator: Estimator
  fileprivate var signalTracker: SignalTracker
  fileprivate var queue: DispatchQueue

  public var mode: Mode {
    return signalTracker is InputSignalTracker ? .record : .playback
  }

  public var levelThreshold: Float? {
    get {
      return self.signalTracker.levelThreshold
    }
    set {
      self.signalTracker.levelThreshold = newValue
    }
  }

  public var signalLevel: Float {
    get { return signalTracker.averageLevel ?? 0.0 }
  }

  // MARK: - Initialization

  public init(config: Config = Config(), delegate: PitchEngineDelegate? = nil) {
    bufferSize = config.bufferSize
    estimator = EstimationFactory.create(config.estimationStrategy)

    if let audioUrl = config.audioUrl {
      signalTracker = OutputSignalTracker(audioUrl: audioUrl, bufferSize: bufferSize)
    } else {
      signalTracker = InputSignalTracker(bufferSize: bufferSize)
    }

    queue = DispatchQueue(label: "BeethovenQueue", attributes: [])
    signalTracker.delegate = self
    self.delegate = delegate
  }

  // MARK: - Processing

  public func start() {
    guard mode == .playback else {
      activate()
      return
    }

    let audioSession = AVAudioSession.sharedInstance()

    switch audioSession.recordPermission() {
    case AVAudioSessionRecordPermission.granted:
      activate()
    case AVAudioSessionRecordPermission.denied:
      DispatchQueue.main.async {
        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
          UIApplication.shared.openURL(settingsURL)
        }
      }
    case AVAudioSessionRecordPermission.undetermined:
      AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted  in
        guard let weakSelf = self else { return }

        guard granted else {
          weakSelf.delegate?.pitchEngineDidReceiveError(weakSelf,
            error: PitchEngineError.recordPermissionDenied as Error)
          return
        }

        DispatchQueue.main.async {
          weakSelf.activate()
        }
      }
    default:
      break
    }
  }

  public func stop() {
    signalTracker.stop()
    active = false
  }

  func activate() {
    do {
      try signalTracker.start()
      active = true
    } catch {
      delegate?.pitchEngineDidReceiveError(self, error: error)
    }
  }
}

// MARK: - SignalTrackingDelegate

extension PitchEngine: SignalTrackerDelegate {

  func signalTracker(_ signalTracker: SignalTracker,
    didReceiveBuffer buffer: AVAudioPCMBuffer, atTime time: AVAudioTime) {
      queue.async { [weak self] in
        guard let weakSelf = self else { return }

        do {
          let transformedBuffer = try weakSelf.estimator.transformer.transform(buffer: buffer)
          let frequency = try weakSelf.estimator.estimateFrequency(
            sampleRate: Float(time.sampleRate),
            buffer: transformedBuffer)
          let pitch = try Pitch(frequency: Double(frequency))

          DispatchQueue.main.async {
            weakSelf.delegate?.pitchEngineDidReceivePitch(weakSelf, pitch: pitch)
          }
        } catch {
          DispatchQueue.main.async {
            weakSelf.delegate?.pitchEngineDidReceiveError(weakSelf, error: error)
          }
        }
    }
  }

  func signalTrackerWentBelowLevelThreshold(_ signalTracker: SignalTracker) {
    DispatchQueue.main.async {
      self.delegate?.pitchEngineWentBelowLevelThreshold(self)
    }
  }
}
