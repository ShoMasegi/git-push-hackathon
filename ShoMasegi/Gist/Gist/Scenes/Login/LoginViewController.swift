import UIKit
import SnapKit
import RxSwift
import NetworkPlatform
import MaterialComponents.MaterialBottomAppBar
import MaterialComponents.MaterialBottomAppBar_ColorThemer


class LoginViewController: UIViewController {
    private let viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSubviews()
        login()
    }

    private lazy var logoView: UILabel = {
        let label = UILabel()
        label.text = "Login"
        label.textAlignment = .center
        return label
    }()

    private func setupSubviews() {
        [logoView].forEach(view.addSubview)
        logoView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func login() {
        viewModel.login(onSuccess: { authToken in
            print(authToken.token)
        }, onError: { message in
            print(message)
        })
    }
}
