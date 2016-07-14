import UIKit
import Beethoven
import Pitchy
import Hue
import Cartography

class ViewController: UIViewController {

  lazy var noteLabel: UILabel = {
    let label = UILabel()
    label.text = "--"
    label.font = UIFont.boldSystemFontOfSize(65)
    label.textColor = UIColor.hex("DCD9DB")
    label.textAlignment = .Center
    label.numberOfLines = 0
    label.sizeToFit()

    return label
    }()

  lazy var offsetLabel: UILabel = { [unowned self] in
    let label = UILabel()
    label.font = UIFont.systemFontOfSize(28)
    label.textColor = UIColor.whiteColor()
    label.textAlignment = .Center
    label.numberOfLines = 0
    label.sizeToFit()

    return label
    }()

  lazy var actionButton: UIButton = { [unowned self] in
    let button = UIButton(type: .System)
    button.layer.cornerRadius = 20
    button.backgroundColor = UIColor.hex("3DAFAE")
    button.titleLabel?.font = UIFont.systemFontOfSize(20)
    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)

    button.addTarget(self, action: #selector(ViewController.actionButtonDidPress(_:)),
      forControlEvents: .TouchUpInside)
    button.setTitle("Start".uppercaseString, forState: .Normal)

    return button
    }()

  lazy var pitchEngine: PitchEngine = { [unowned self] in
    let pitchEngine = PitchEngine(delegate: self)
    pitchEngine.levelThreshold = -30.0

    return pitchEngine
    }()

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Tuner".uppercaseString
    view.backgroundColor = UIColor.hex("111011")

    [noteLabel, actionButton, offsetLabel].forEach {
      view.addSubview($0)
    }

    setupLayout()
  }

  // MARK: - Action methods

  func actionButtonDidPress(button: UIButton) {
    let text = pitchEngine.active
      ? NSLocalizedString("Start", comment: "").uppercaseString
      : NSLocalizedString("Stop", comment: "").uppercaseString

    button.setTitle(text, forState: .Normal)
    button.backgroundColor = pitchEngine.active
      ? UIColor.hex("3DAFAE")
      : UIColor.hex("E13C6C")

    noteLabel.text = "--"
    pitchEngine.active ? pitchEngine.stop() : pitchEngine.start()
    offsetLabel.hidden = !pitchEngine.active
  }

  // MARK: - Constrains

  func setupLayout() {
    let totalSize = UIScreen.mainScreen().bounds

    constrain(actionButton, noteLabel, offsetLabel) {
      actionButton, noteLabel, offsetLabel in

      let superview = actionButton.superview!

      actionButton.top == superview.top + (totalSize.height - 30) / 2
      actionButton.centerX == superview.centerX
      actionButton.width == 280
      actionButton.height == 50

      offsetLabel.bottom == actionButton.top - 60
      offsetLabel.leading == superview.leading
      offsetLabel.trailing == superview.trailing
      offsetLabel.height == 80

      noteLabel.bottom == offsetLabel.top - 20
      noteLabel.leading == superview.leading
      noteLabel.trailing == superview.trailing
      noteLabel.height == 80
    }
  }

  // MARK: - UI

  func offsetColor(offsetPercentage: Double) -> UIColor {
    let color: UIColor

    switch abs(offsetPercentage) {
    case 0...5:
      color = UIColor.hex("3DAFAE")
    case 6...25:
      color = UIColor.hex("FDFFB1")
    default:
      color = UIColor.hex("E13C6C")
    }

    return color
  }
}

// MARK: - PitchEngineDelegate

extension ViewController: PitchEngineDelegate {

  func pitchEngineDidRecievePitch(pitchEngine: PitchEngine, pitch: Pitch) {
    noteLabel.text = pitch.note.string

    let offsetPercentage = pitch.closestOffset.percentage
    let absOffsetPercentage = abs(offsetPercentage)

    NSLog("pitch : \(pitch.note.string) - percentage : \(offsetPercentage)")

    guard absOffsetPercentage > 1.0 else {
      return
    }

    let prefix = offsetPercentage > 0 ? "+" : "-"
    let color = offsetColor(offsetPercentage)

    offsetLabel.text = "\(prefix)" + String(format:"%.2f", absOffsetPercentage) + "%"
    offsetLabel.textColor = color
    offsetLabel.hidden = false
  }

  func pitchEngineDidRecieveError(pitchEngine: PitchEngine, error: ErrorType) {
    print(error)
  }
}
