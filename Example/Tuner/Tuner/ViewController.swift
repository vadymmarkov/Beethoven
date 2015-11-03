import UIKit
import PitchAssistant

class ViewController: UIViewController {

  lazy var pitchEngine: PitchEngine = { [unowned self] in
    let pitchEngine = PitchEngine(
      bufferSize: 2048,
      delegate: self
    )

    return pitchEngine
    }()

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Tuner"
  }
}

// MARK: - PitchEngineDelegate

extension ViewController: PitchEngineDelegate {

  func pitchEngineDidRecieveFrequency(pitchEngine: PitchEngine, frequency: Float) {

  }
}

