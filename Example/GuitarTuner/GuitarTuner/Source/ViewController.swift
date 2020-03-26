import UIKit
import Beethoven
import Pitchy
import Hue
import Cartography

final class ViewController: UIViewController {
  lazy var noteLabel: UILabel = {
    let label = UILabel()
    label.text = "--"
    label.font = UIFont.boldSystemFont(ofSize: 65)
    label.textColor = UIColor(hex: "DCD9DB")
    label.textAlignment = .center
    label.numberOfLines = 0
    label.sizeToFit()
    return label
  }()

  lazy var offsetLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 28)
    label.textColor = UIColor.white
    label.textAlignment = .center
    label.numberOfLines = 0
    label.sizeToFit()
    return label
  }()

  lazy var actionButton: UIButton = { [unowned self] in
    let button = UIButton(type: .system)
    button.layer.cornerRadius = 20
    button.backgroundColor = UIColor(hex: "3DAFAE")
    button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
    button.setTitleColor(UIColor.white, for: UIControl.State())

    button.addTarget(self, action: #selector(ViewController.actionButtonDidPress(_:)),
      for: .touchUpInside)
    button.setTitle("Start".uppercased(), for: UIControl.State())

    return button
  }()

  lazy var pitchEngine: PitchEngine = { [weak self] in
    let config = Config(estimationStrategy: .yin)
    let pitchEngine = PitchEngine(config: config, delegate: self)
    pitchEngine.levelThreshold = -30.0
    return pitchEngine
  }()

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Tuner".uppercased()
    view.backgroundColor = UIColor(hex: "111011")

    [noteLabel, actionButton, offsetLabel].forEach {
      view.addSubview($0)
    }

    setupLayout()
  }

  // MARK: - Action methods

  @objc func actionButtonDidPress(_ button: UIButton) {
    let text = pitchEngine.active
      ? NSLocalizedString("Start", comment: "").uppercased()
      : NSLocalizedString("Stop", comment: "").uppercased()

    button.setTitle(text, for: .normal)
    button.backgroundColor = pitchEngine.active
      ? UIColor(hex: "3DAFAE")
      : UIColor(hex: "E13C6C")

    noteLabel.text = "--"
    pitchEngine.active ? pitchEngine.stop() : pitchEngine.start()
    offsetLabel.isHidden = !pitchEngine.active
  }

  // MARK: - Layout

  func setupLayout() {
    let totalSize = UIScreen.main.bounds

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

  private func offsetColor(_ offsetPercentage: Double) -> UIColor {
    let color: UIColor

    switch abs(offsetPercentage) {
    case 0...5:
      color = UIColor(hex: "3DAFAE")
    case 6...25:
      color = UIColor(hex: "FDFFB1")
    default:
      color = UIColor(hex: "E13C6C")
    }

    return color
  }
}

// MARK: - PitchEngineDelegate

extension ViewController: PitchEngineDelegate {
  func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Pitch) {
    noteLabel.text = pitch.note.string

    let offsetPercentage = pitch.closestOffset.percentage
    let absOffsetPercentage = abs(offsetPercentage)

    print("pitch : \(pitch.note.string) - percentage : \(offsetPercentage)")

    guard absOffsetPercentage > 1.0 else {
      return
    }

    let prefix = offsetPercentage > 0 ? "+" : "-"
    let color = offsetColor(offsetPercentage)

    offsetLabel.text = "\(prefix)" + String(format:"%.2f", absOffsetPercentage) + "%"
    offsetLabel.textColor = color
    offsetLabel.isHidden = false
  }

  func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) {
    print(error)
  }

  public func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
    print("Below level threshold")
  }
}
