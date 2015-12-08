import AVFoundation

public protocol SignalTrackerDelegate: class {

  func signalTracker(signalTracker: SignalTracker,
    didReceiveBuffer buffer: AVAudioPCMBuffer,
    atTime time: AVAudioTime)
}

public protocol SignalTracker: class {
  
  weak var delegate: SignalTrackerDelegate? { get set }

  func start() throws
  func stop()
}
