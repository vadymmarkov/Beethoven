import UIKit
import Beethoven
import Pitchy
import Hue
import Cartography

class ViewController: UIViewController {

  lazy var noteLabel: UILabel = {
    let label = UILabel()
    label.text = "A4"
    label.font = UIFont.boldSystemFontOfSize(70)
    label.textColor = UIColor.hex("DCD9DB")
    label.textAlignment = .Center
    label.numberOfLines = 0
    label.sizeToFit()

    return label
  }()

  lazy var leftOffsetLabel: UILabel = {
    let label = UILabel()
    label.text = "+50%"
    label.font = UIFont.systemFontOfSize(24)
    label.textColor = UIColor.whiteColor()
    label.textAlignment = .Center
    label.numberOfLines = 0
    label.sizeToFit()

    return label
  }()

  lazy var rightOffsetLabel: UILabel = {
    let label = UILabel()
    label.text = "-50%"
    label.font = UIFont.systemFontOfSize(24)
    label.textColor = UIColor.whiteColor()
    label.textAlignment = .Center
    label.numberOfLines = 0
    label.sizeToFit()

    return label
  }()

  lazy var actionButton: UIButton = { [unowned self] in
    let button = UIButton(type: .System)
    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    button.layer.cornerRadius = 20
    button.backgroundColor = UIColor.hex("E13C6C")

    button.addTarget(self, action: "actionButtonDidPress:",
      forControlEvents: .TouchUpInside)
    button.setTitle("Start".uppercaseString, forState: .Normal)
    button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 18)!

    return button
  }()

  lazy var tuner: PitchEngine = { [unowned self] in
    let pitchEngine = PitchEngine(
      delegate: self
    )

    return pitchEngine
  }()

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Pitchy".uppercaseString
    view.backgroundColor = UIColor.hex("181717")


    //let gradientLayer = [UIColor.hex("224AAA"), UIColor.hex("3DAFAE")].gradient()
    //gradientLayer.frame = view.frame
    //view.layer.insertSublayer(gradientLayer, atIndex: 0)

    [noteLabel, actionButton, leftOffsetLabel, rightOffsetLabel].forEach {
      view.addSubview($0)
    }

    setupLayout()
  }

  // MARK: - Action methods

  func actionButtonDidPress(button: UIButton) {
    noteLabel.text = "--"
    tuner.active ? tuner.stop() : tuner.start()
    tuner.active
      ? button.setTitle("Stop".uppercaseString, forState: .Normal)
      : button.setTitle("Start".uppercaseString, forState: .Normal)
  }

  // MARK: - Constrains

  func setupLayout() {
    let totalSize = UIScreen.mainScreen().bounds

    constrain(actionButton, noteLabel) { actionButton, noteLabel in
      let superview = actionButton.superview!

      actionButton.top == superview.top + (totalSize.height - 100) / 2
      actionButton.centerX == superview.centerX
      actionButton.width == 280
      actionButton.height == 50

      noteLabel.top == actionButton.top - 180
      noteLabel.centerX == superview.centerX
      noteLabel.width == 100
      noteLabel.height == 80
    }

    constrain(noteLabel, leftOffsetLabel, rightOffsetLabel) {
      noteLabel, leftOffsetLabel, rightOffsetLabel in

      leftOffsetLabel.top == noteLabel.top
      leftOffsetLabel.right == noteLabel.left - 25
      leftOffsetLabel.width == 70
      leftOffsetLabel.height == 80

      rightOffsetLabel.top == noteLabel.top
      rightOffsetLabel.left == noteLabel.right + 25
      rightOffsetLabel.width == 70
      rightOffsetLabel.height == 80
    }
  }
}

// MARK: - PitchEngineDelegate

extension ViewController: PitchEngineDelegate {

  func pitchEngineDidRecievePitch(pitchEngine: PitchEngine, pitch: Pitch) {
    noteLabel.text = pitch.note.string

    let offsetPercentage = pitch.closestOffset.percentage
    let label = offsetPercentage > 0 ? rightOffsetLabel : leftOffsetLabel

    label.text = "\(offsetPercentage)%"
  }

  func pitchEngineDidRecieveError(pitchEngine: PitchEngine, error: ErrorType) {
    print(error)
  }
}
