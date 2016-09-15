import UIKit
import AVFoundation
import Pitchy

public protocol PitchEngineDelegate: class {
  func pitchEngineDidRecievePitch(_ pitchEngine: PitchEngine, pitch: Pitch)
  func pitchEngineDidRecieveError(_ pitchEngine: PitchEngine, error: Error)
}

open class PitchEngine {

  public enum PitchEngineError: Error {
    case recordPermissionDenied
  }

  public enum Mode {
    case record, playback
  }

  open let bufferSize: AVAudioFrameCount
  open var active = false
  open weak var delegate: PitchEngineDelegate?

  fileprivate var transformer: Transformer
  fileprivate var estimator: Estimator
  fileprivate var signalTracker: SignalTracker
  fileprivate var queue: DispatchQueue

  open var mode: Mode {
    return signalTracker is InputSignalTracker ? .record : .playback
  }

  open var levelThreshold:Float? {
    get {
      return self.signalTracker.levelThreshold
    }
    set {
      self.signalTracker.levelThreshold = newValue
    }
  }

  // MARK: - Initialization

  public init(config: Config = Config(), delegate: PitchEngineDelegate? = nil) {
    bufferSize = config.bufferSize
    transformer = TransformFactory.create(config.transformStrategy)
    estimator = EstimationFactory.create(config.estimationStrategy)

    if let audioURL = config.audioURL {
      signalTracker = OutputSignalTracker(audioURL: audioURL, bufferSize: bufferSize)
    } else {
      signalTracker = InputSignalTracker(bufferSize: bufferSize)
    }

    queue = DispatchQueue(label: "BeethovenQueue", attributes: [])

    signalTracker.delegate = self

    self.delegate = delegate
  }

  // MARK: - Processing

  open func start() {
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
          weakSelf.delegate?.pitchEngineDidRecieveError(weakSelf,
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

  open func stop() {
    signalTracker.stop()
    active = false
  }

  func activate() {
    do {
      try signalTracker.start()
      active = true
    } catch {
      delegate?.pitchEngineDidRecieveError(self, error: error)
    }
  }
}

// MARK: - SignalTrackingDelegate

extension PitchEngine: SignalTrackerDelegate {

  public func signalTracker(_ signalTracker: SignalTracker,
    didReceiveBuffer buffer: AVAudioPCMBuffer, atTime time: AVAudioTime) {
      queue.async { [weak self] in
        guard let weakSelf = self else { return }

        let transformedBuffer = weakSelf.transformer.transformBuffer(buffer)

        do {
          let frequency = try weakSelf.estimator.estimateFrequency(Float(time.sampleRate),
            buffer: transformedBuffer)
          let pitch = try Pitch(frequency: Double(frequency))

          DispatchQueue.main.async {
            weakSelf.delegate?.pitchEngineDidRecievePitch(weakSelf, pitch: pitch)
          }
        } catch {
          DispatchQueue.main.async {
            weakSelf.delegate?.pitchEngineDidRecieveError(weakSelf, error: error)
          }
        }
    }
  }
}
