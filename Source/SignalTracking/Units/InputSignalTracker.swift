import AVFoundation

public class InputSignalTracker: SignalTracker {

  public enum Error: ErrorType {
    case InputNodeMissing
  }

  public let bufferSize: AVAudioFrameCount
  public weak var delegate: SignalTrackerDelegate?
  public var levelThreshold: Float?

  var audioChannel: AVCaptureAudioChannel?
  let captureSession = AVCaptureSession()
  private var audioEngine: AVAudioEngine!
  private let session = AVAudioSession.sharedInstance()
  private let bus = 0

  private var signalPeakLevel: Float {
    get {
      return audioChannel?.peakHoldLevel ?? 0.0
    }
  }

  private var signalAverageLevel: Float {
    get {
      return audioChannel?.averagePowerLevel ?? 0.0
    }
  }

  // MARK: - Initialization

  public required init(bufferSize: AVAudioFrameCount = 2048, delegate: SignalTrackerDelegate? = nil) {
    self.bufferSize = bufferSize
    self.delegate = delegate

    setupAudio()
  }

  // MARK: - Tracking

  public func start() throws {
    try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
    try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)

    audioEngine = AVAudioEngine()

    guard let inputNode = audioEngine.inputNode else {
      throw Error.InputNodeMissing
    }

    let format = inputNode.inputFormatForBus(bus)

    inputNode.installTapOnBus(bus, bufferSize: bufferSize, format: format) { buffer, time in

      let levelThreshold = self.levelThreshold ?? -1000000.0

      if self.signalAverageLevel > levelThreshold {
        dispatch_async(dispatch_get_main_queue()) {
          self.delegate?.signalTracker(self, didReceiveBuffer: buffer, atTime: time)
        }
      }
    }

    captureSession.startRunning()
    audioEngine.prepare()
    try audioEngine.start()
  }

  public func stop() {
    audioEngine.stop()
    audioEngine.reset()
    audioEngine = nil
    captureSession.stopRunning()
  }

  func setupAudio() {
    do {
      let audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
      let audioCaptureInput = try AVCaptureDeviceInput(device: audioDevice)

      captureSession.addInput(audioCaptureInput)

      let audioOutput = AVCaptureAudioDataOutput()

      captureSession.addOutput(audioOutput)

      let connection = audioOutput.connections[0] as! AVCaptureConnection
      let firstAudioChannel = connection.audioChannels[0] as! AVCaptureAudioChannel

      audioChannel = firstAudioChannel
    } catch {}
  }
}
