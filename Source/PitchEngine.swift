import UIKit
import AVFoundation
import Pitchy

public protocol PitchEngineDelegate: class {
  func pitchEngineDidReceivePitch(_ pitchEngine: PitchEngine, pitch: Pitch)
  func pitchEngineDidReceiveError(_ pitchEngine: PitchEngine, error: Error)
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
          weakSelf.delegate?.pitchEngineDidReceiveError(
            weakSelf,
            error: Error.recordPermissionDenied
          )
          return
        }

        DispatchQueue.main.async {
          weakSelf.activate()
        }
      }
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
  public func signalTracker(_ signalTracker: SignalTracker,
                            didReceiveBuffer buffer: AVAudioPCMBuffer,
                            atTime time: AVAudioTime) {
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

  public func signalTrackerWentBelowLevelThreshold(_ signalTracker: SignalTracker) {
    DispatchQueue.main.async {
      self.delegate?.pitchEngineWentBelowLevelThreshold(self)
    }
  }
}
