import AVFoundation

public protocol SignalTrackerDelegate: class {

  func signalTracker(_ signalTracker: SignalTracker,
    didReceiveBuffer buffer: AVAudioPCMBuffer,
    atTime time: AVAudioTime)
}

public protocol SignalTracker: class {

  var levelThreshold:Float? { get set }
  weak var delegate: SignalTrackerDelegate? { get set }

  func start() throws
  func stop()
}
