import Foundation
import AVFoundation

public protocol TransformAware {

  func transformBuffer(buffer: AVAudioPCMBuffer) -> Buffer
}
