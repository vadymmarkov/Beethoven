import UIKit
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
    case Record, Playback
  }

  public let bufferSize: AVAudioFrameCount
  public var active = false
  public weak var delegate: PitchEngineDelegate?

  private var transformer: Transformer
  private var estimator: Estimator
  private var signalTracker: SignalTracker
  private var queue: dispatch_queue_t

  public var mode: Mode {
    return signalTracker is InputSignalTracker ? .Record : .Playback
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

    queue = dispatch_queue_create("BeethovenQueue", DISPATCH_QUEUE_SERIAL)

    signalTracker.delegate = self

    self.delegate = delegate
  }

  // MARK: - Processing

  public func start() {
    guard mode == .Playback else {
      activate()
      return
    }

    let audioSession = AVAudioSession.sharedInstance()

    switch audioSession.recordPermission() {
    case AVAudioSessionRecordPermission.Granted:
      activate()
    case AVAudioSessionRecordPermission.Denied:
      dispatch_async(dispatch_get_main_queue()) {
        if let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) {
          UIApplication.sharedApplication().openURL(settingsURL)
        }
      }
    case AVAudioSessionRecordPermission.Undetermined:
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
      delegate?.pitchEngineDidRecieveError(self, error: error)
    }
  }
}

// MARK: - SignalTrackingDelegate

extension PitchEngine: SignalTrackerDelegate {

  public func signalTracker(signalTracker: SignalTracker,
    didReceiveBuffer buffer: AVAudioPCMBuffer, atTime time: AVAudioTime) {
      dispatch_async(queue) { [weak self] in
        guard let weakSelf = self else { return }

        let transformedBuffer = weakSelf.transformer.transformBuffer(buffer)

        do {
          let frequency = try weakSelf.estimator.estimateFrequency(Float(time.sampleRate),
            buffer: transformedBuffer)
          let pitch = try Pitch(frequency: Double(frequency))

          dispatch_async(dispatch_get_main_queue()) {
            weakSelf.delegate?.pitchEngineDidRecievePitch(weakSelf, pitch: pitch)
          }
        } catch {
          dispatch_async(dispatch_get_main_queue()) {
            weakSelf.delegate?.pitchEngineDidRecieveError(weakSelf, error: error)
          }
        }
    }
  }
}
