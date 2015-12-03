import AVFoundation

public protocol SignalTrackingDelegate: class {

  func signalTracker(signalTracker: SignalTrackingAware,
    didReceiveBuffer buffer: AVAudioPCMBuffer,
    atTime time: AVAudioTime)
}

public protocol SignalTrackingAware: class {
  
  weak var delegate: SignalTrackingDelegate? { get set }

  func start() throws
  func stop()
}
