import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Moya
import NetworkPlatform
import Domain

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

        Networking.newDefaultNetworking()
                .request(.login(username: "ShoMasegi", password: "ShoMasegi0227", otp: nil))
                .filterAPIError()
                .map(to: BasicAuthToken.self)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { response in
                    print("success: \(response.data.token)")
                }, onError: { error in
                    if let apiError = error as? APIError {
                        print(apiError.message)
                    } else {
                        print(error.localizedDescription)
                    }
                })
                .disposed(by: bag)
//
//        viewModel.getEvens(onSuccess: { _ in
//            let navigationController = UINavigationController()
//            let navigator = MainNavigator(navigationController: navigationController)
//            Application.shared.rootViewController.animateFadeTransition(to: navigationController) {
//                navigator.toRoot()
//            }
//        }, onError: { message in
//            self.presentAlert(message: message)
//        })
    }

    func appDidBecomeActive() {
        prepare()
    }
}
