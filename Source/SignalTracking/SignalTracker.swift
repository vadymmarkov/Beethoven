import AVFoundation

protocol SignalTrackerDelegate: class {
  func signalTracker(_ signalTracker: SignalTracker,
    didReceiveBuffer buffer: AVAudioPCMBuffer,
    atTime time: AVAudioTime)

  func signalTrackerWentBelowLevelThreshold(_ signalTracker: SignalTracker)
}

protocol SignalTracker: class {
  var levelThreshold: Float? { get set }
  var peakLevel: Float? { get }
  var averageLevel: Float? { get }
  weak var delegate: SignalTrackerDelegate? { get set }

  func start() throws
  func stop()
}
