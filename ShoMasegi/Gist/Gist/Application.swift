import UIKit

final class Application {

    static let shared = Application()
    let rootViewController: RootViewController = RootViewController()

    private init() {}

    func setup(in window: UIWindow) {
        rootViewController.current = SplashViewController()
        window.rootViewController = self.rootViewController
        window.makeKeyAndVisible()
    }
}
