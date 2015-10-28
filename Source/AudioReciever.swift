import Foundation
import AudioToolbox

public protocol AudioReceiverDelegate: class {

  func audioReceiverDidCaptureSamples(
    audioReceiver: AudioReceiver,
    samples: UnsafeMutablePointer<Int16>,
    length: Int)
}

public class AudioReceiver {
  
}
