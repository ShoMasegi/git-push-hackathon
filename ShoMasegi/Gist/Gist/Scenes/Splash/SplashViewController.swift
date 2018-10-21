import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Moya
import NetworkPlatform
import Domain

class SplashViewController: UIViewController {
    private let viewModel: SplashViewModel

    init() {
        let provider = UseCaseProvider(networking: Networking.newDefaultNetworking())
        viewModel = SplashViewModel(useCase: provider.makeUserUserCase())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder _: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSubviews()
        prepare()
    }

    private let bag = DisposeBag()

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
        viewModel.user(onSuccess: { _ in
            let navigationController = UINavigationController()
            let provider = Application.shared.defaultUseCaseProvider()
            let navigator = GistNavigator(provider: provider, navigationController: navigationController)
            Application.shared.rootViewController.animateFadeTransition(to: navigationController) {
                navigator.toRoot()
            }
        }, onError: { _ in
            let navigationController = UINavigationController()
            let provider = UseCaseProvider(networking: Networking.newDefaultNetworking())
            let navigator = LoginNavigator(provider: provider, navigationController: navigationController)
            Application.shared.rootViewController.animateFadeTransition(to: navigationController) {
                navigator.toRoot()
            }
        })

    }

    func appDidBecomeActive() {
        prepare()
    }
}
