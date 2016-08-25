import AVFoundation

public protocol SignalTrackerDelegate: class {

  func signalTracker(signalTracker: SignalTracker,
    didReceiveBuffer buffer: AVAudioPCMBuffer,
    atTime time: AVAudioTime)
}

public protocol SignalTracker: class {

  var levelThreshold:Float? { get set }
  var peakLevel:Float? { get }
  var averageLevel:Float? { get }
  weak var delegate: SignalTrackerDelegate? { get set }

  func start() throws
  func stop()
}
