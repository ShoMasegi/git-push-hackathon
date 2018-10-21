import UIKit
import Domain
import Library
import KeychainAccess

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var applicationIsReturningBackground: Bool = false


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppEnvironment.replaceCurrentEnvironment(
                AppEnvironment.fromStorage(
                        userDefaults: UserDefaults.standard,
                        keychain: Keychain()
                )
        )
        setupNavigationBar()
        setupWindow()
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        applicationIsReturningBackground = true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if applicationIsReturningBackground {
            applicationIsReturningBackground = false
            
            if let lockViewController = Application.shared.rootViewController.current as? LockViewController {
                lockViewController.appDidBecomeActive()
            } else if let splashViewController = Application.shared.rootViewController as? SplashViewController {
                splashViewController.appDidBecomeActive()
            }
        }
    }
    
    private func setupNavigationBar() {
        window = {
            let window = UIWindow(frame: UIScreen.main.bounds)
            Application.shared.setup(in: window)
            return window
        }()
    }
    
    private func setupWindow() {
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().isHidden = true
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().isTranslucent = false
    }
}

extension AppDelegate {
    
    var rootViewController: RootViewController? {
        return window?.rootViewController as? RootViewController
    }
}

