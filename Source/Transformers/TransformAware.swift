import Foundation
import AVFoundation

public protocol TransformAware {

  func transformBuffer(buffer: AVAudioPCMBuffer, atTime time: AVAudioTime) -> TransformResult
}
