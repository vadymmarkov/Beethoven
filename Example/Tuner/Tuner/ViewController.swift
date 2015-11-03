import UIKit
import PitchAssistant

class ViewController: UIViewController {

  lazy var noteLabel: UILabel = {
    let label = UILabel()
    label.text = "--"
    label.font = UIFont(name: "HelveticaNeue-Medium", size: 30)!
    label.textColor = UIColor(red:0.86, green:0.86, blue:0.86, alpha:1)
    label.textAlignment = .Center
    label.numberOfLines = 0
    label.sizeToFit()

    return label
    }()

  lazy var actionButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.setTitleColor(UIColor.grayColor(), forState: .Normal)
    button.layer.borderColor = UIColor.grayColor().CGColor
    button.layer.borderWidth = 1.5
    button.layer.cornerRadius = 7.5

    button.addTarget(self, action: "actionButtonDidPress:",
      forControlEvents: .TouchUpInside)
    button.setTitle("Start", forState: .Normal)

    return button
    }()

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
    view.backgroundColor = UIColor.whiteColor()

    [noteLabel, actionButton].forEach {
      view.addSubview($0)
    }

    setupLayout()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    setupLayout()
  }

  // MARK: - Action methods

  func actionButtonDidPress(button: UIButton) {
    pitchEngine.active ? pitchEngine.stop() : pitchEngine.start()
    pitchEngine.active
      ? button.setTitle("Stop", forState: .Normal)
      : button.setTitle("Start", forState: .Normal)
  }

  // MARK: - Configuration

  func setupLayout() {
    let totalSize = UIScreen.mainScreen().bounds

    noteLabel.frame.origin = CGPoint(x: (totalSize.width - noteLabel.frame.width) / 2, y: 90)
    actionButton.frame = CGRect(x: 50, y: noteLabel.frame.maxY + 50,
      width: totalSize.width - 100, height: 50)
  }
}

// MARK: - PitchEngineDelegate

extension ViewController: PitchEngineDelegate {

  func pitchEngineDidRecieveFrequency(pitchEngine: PitchEngine, frequency: Float) {

  }
}

