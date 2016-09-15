import AVFoundation

open class InputSignalTracker: SignalTracker {

  public enum InputSignalTrackerError: Error {
    case inputNodeMissing
  }

  open let bufferSize: AVAudioFrameCount
  open weak var delegate: SignalTrackerDelegate?
  open var levelThreshold: Float?

  var audioChannel: AVCaptureAudioChannel?
  let captureSession = AVCaptureSession()
  fileprivate var audioEngine: AVAudioEngine?
  fileprivate let session = AVAudioSession.sharedInstance()
  fileprivate let bus = 0

  fileprivate var signalPeakLevel: Float {
    get {
      return audioChannel?.peakHoldLevel ?? 0.0
    }
  }

  fileprivate var signalAverageLevel: Float {
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

  open func start() throws {
    try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
    try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)

    audioEngine = AVAudioEngine()

    guard let inputNode = audioEngine?.inputNode else {
      throw InputSignalTrackerError.inputNodeMissing
    }

    let format = inputNode.inputFormat(forBus: bus)

    inputNode.installTap(onBus: bus, bufferSize: bufferSize, format: format) { buffer, time in

      let levelThreshold = self.levelThreshold ?? -1000000.0

      if self.signalAverageLevel > levelThreshold {
        DispatchQueue.main.async {
          self.delegate?.signalTracker(self, didReceiveBuffer: buffer, atTime: time)
        }
      }
    }

    captureSession.startRunning()
    audioEngine?.prepare()
    try audioEngine?.start()
  }

  open func stop() {
    guard audioEngine != nil else {
      return
    }

    audioEngine?.stop()
    audioEngine?.reset()
    audioEngine = nil
    captureSession.stopRunning()
  }

  func setupAudio() {
    do {
      let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
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
