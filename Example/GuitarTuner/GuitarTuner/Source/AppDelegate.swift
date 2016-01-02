import UIKit
import Hue

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  lazy var navigationController: UINavigationController = { [unowned self] in
    let controller = UINavigationController(rootViewController: self.viewController)
    return controller
    }()

  lazy var viewController: ViewController = {
    let controller = ViewController()
    return controller
    }()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window?.rootViewController = navigationController

    applyStyles()

    window?.makeKeyAndVisible()

    return true
  }

  func applyStyles() {
    let navigationBar = UINavigationBar.appearance()
    navigationBar.barStyle = .Black
    navigationBar.barTintColor = UIColor.hex("111011")
    navigationBar.translucent = false
    navigationBar.shadowImage = UIImage()
    navigationBar.titleTextAttributes = [
      NSForegroundColorAttributeName: UIColor.whiteColor()
    ]
  }
}
