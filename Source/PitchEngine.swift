import UIKit
import AVFoundation
import Pitchy

public protocol PitchEngineDelegate: AnyObject {
  func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Pitch)
  func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error)
  func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine)
}

public final class PitchEngine {
  public enum Error: Swift.Error {
    case recordPermissionDenied
  }

  public let bufferSize: AVAudioFrameCount
  public private(set) var active = false
  public weak var delegate: PitchEngineDelegate?

  private let estimator: Estimator
  private let signalTracker: SignalTracker
  private let queue: DispatchQueue

  public var mode: SignalTrackerMode {
    return signalTracker.mode
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
    return signalTracker.averageLevel ?? 0.0
  }

  // MARK: - Initialization

  public init(config: Config = Config(),
              signalTracker: SignalTracker? = nil,
              delegate: PitchEngineDelegate? = nil) {
    bufferSize = config.bufferSize

    let factory = EstimationFactory()
    estimator = factory.create(config.estimationStrategy)

    if let signalTracker = signalTracker {
      self.signalTracker = signalTracker
    } else {
      if let audioUrl = config.audioUrl {
        self.signalTracker = OutputSignalTracker(audioUrl: audioUrl, bufferSize: bufferSize)
      } else {
        self.signalTracker = InputSignalTracker(bufferSize: bufferSize)
      }
    }

    self.queue = DispatchQueue(label: "BeethovenQueue", attributes: [])
    self.signalTracker.delegate = self
    self.delegate = delegate
  }

  // MARK: - Processing

  public func start() {
    guard mode == .playback else {
      activate()
      return
    }

    let audioSession = AVAudioSession.sharedInstance()

    switch audioSession.recordPermission {
    case AVAudioSession.RecordPermission.granted:
      activate()
    case AVAudioSession.RecordPermission.denied:
      DispatchQueue.main.async {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(settingsURL)
            }
        }
      }
    case AVAudioSession.RecordPermission.undetermined:
      AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted  in
        guard let weakSelf = self else { return }

        guard granted else {
          weakSelf.delegate?.pitchEngine(weakSelf,
                                         didReceiveError: Error.recordPermissionDenied)
          return
        }

        DispatchQueue.main.async {
          weakSelf.activate()
        }
      }
    @unknown default:
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
      delegate?.pitchEngine(self, didReceiveError: error)
    }
  }
}

// MARK: - SignalTrackingDelegate

extension PitchEngine: SignalTrackerDelegate {
  public func signalTracker(_ signalTracker: SignalTracker,
                            didReceiveBuffer buffer: AVAudioPCMBuffer,
                            atTime time: AVAudioTime) {
      queue.async { [weak self] in
        guard let `self` = self else { return }

        do {
          let transformedBuffer = try self.estimator.transformer.transform(buffer: buffer)
          let frequency = try self.estimator.estimateFrequency(
            sampleRate: Float(time.sampleRate),
            buffer: transformedBuffer)
          let pitch = try Pitch(frequency: Double(frequency))

          DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.pitchEngine(self, didReceivePitch: pitch)
          }
        } catch {
          DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.pitchEngine(self, didReceiveError: error)
          }
        }
    }
  }

  public func signalTrackerWentBelowLevelThreshold(_ signalTracker: SignalTracker) {
    DispatchQueue.main.async {
      self.delegate?.pitchEngineWentBelowLevelThreshold(self)
    }
  }
}
