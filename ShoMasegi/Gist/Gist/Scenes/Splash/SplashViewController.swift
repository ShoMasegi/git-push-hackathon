import UIKit
import SnapKit

class SplashViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder _: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSubviews()
        prepare()
    }

    private lazy var logoView: UILabel = {
        let label = UILabel()
        label.text = "Gist"
        label.textAlignment = .center
        return label
    }()

    private func setupSubviews() {
        [logoView].forEach(view.addSubview)
        logoView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func prepare() {
        let navigationController = UINavigationController()
        let navigator = MainNavigator(navigationController: navigationController)
        Application.shared.rootViewController.animateFadeTransition(to: navigationController) {
            navigator.toRoot()
        }
    }

    func appDidBecomeActive() {
        prepare()
    }
}
