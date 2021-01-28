import UIKit
import Hue

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  lazy var navigationController: UINavigationController = .init(rootViewController: self.viewController)
  lazy var viewController: ViewController = .init()

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = navigationController

    applyStyles()

    window?.makeKeyAndVisible()

    return true
  }

  private func applyStyles() {
    let navigationBar = UINavigationBar.appearance()
    navigationBar.barStyle = .black
    navigationBar.barTintColor = UIColor(hex: "111011")
    navigationBar.isTranslucent = false
    navigationBar.shadowImage = UIImage()
    navigationBar.titleTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.white
    ]
  }
}
