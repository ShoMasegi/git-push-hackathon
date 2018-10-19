import UIKit

final class MainNavigator {

    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    func toRoot() {
        let viewController = UIViewController()
        navigationController?.pushViewController(viewController, animated: false)
    }
}
