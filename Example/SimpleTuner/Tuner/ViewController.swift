import UIKit
import Hex
import Tuner
import Pitchy

class ViewController: UIViewController {

  lazy var noteLabel: UILabel = {
    let label = UILabel()
    label.text = "--"
    label.font = UIFont(name: "HelveticaNeue-Medium", size: 30)!
    label.textColor = UIColor(hex: "DCD9DB")
    label.textAlignment = .Center
    label.numberOfLines = 0
    label.sizeToFit()

    return label
    }()

  lazy var actionButton: UIButton = { [unowned self] in
    let button = UIButton(type: .System)
    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    button.layer.cornerRadius = 20
    button.backgroundColor = UIColor(hex: "E13C6C")

    button.addTarget(self, action: "actionButtonDidPress:",
      forControlEvents: .TouchUpInside)
    button.setTitle("Start".uppercaseString, forState: .Normal)
    button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 18)!

    return button
    }()

  lazy var tuner: Tuner = { [unowned self] in
    let pitchEngine = Tuner(
      bufferSize: 2048,
      delegate: self
    )

    return pitchEngine
    }()

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Pitchy".uppercaseString
    view.backgroundColor = UIColor(hex: "181717")

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
    tuner.active ? tuner.stop() : tuner.start()
    tuner.active
      ? button.setTitle("Stop".uppercaseString, forState: .Normal)
      : button.setTitle("Start".uppercaseString, forState: .Normal)
  }

  // MARK: - Configuration

  func setupLayout() {
    let totalSize = UIScreen.mainScreen().bounds

    actionButton.frame = CGRect(x: 50, y: (totalSize.height - 120) / 2,
      width: totalSize.width - 100, height: 50)
    noteLabel.frame = CGRect(x: 0, y: actionButton.frame.minY - 140,
      width: totalSize.width, height: 40)
  }
}

// MARK: - TunerDelegate

extension ViewController: TunerDelegate {

  func tunerDidRecievePitch(tuner: Tuner, pitch: Pitch) {
    noteLabel.text = pitch.note.string
  }
}
