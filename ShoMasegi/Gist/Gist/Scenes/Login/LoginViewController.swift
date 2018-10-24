import UIKit
import SnapKit
import RxSwift
import RxCocoa
import NetworkPlatform
import SVProgressHUD
import Domain

class LoginViewController: UIViewController {

    private let viewModel: LoginViewModel
    private let bag = DisposeBag()

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) { fatalError() }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .primary_main
        registerKeyboardNotifications()
        setupSubviews()
        bind()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
    }

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            self?.view.endEditing(true)
        }).disposed(by: bag)
        view.addGestureRecognizer(tap)
        view.translatesAutoresizingMaskIntoConstraints = false
        let marginOffset: CGFloat = 24
        let margins = UIEdgeInsets(top: 0, left: marginOffset, bottom: 0, right: marginOffset)
        view.layoutMargins = margins
        return view
    }()
    private lazy var logoView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "logo")
        view.clipsToBounds = true
        view.contentMode = .scaleToFill
        return view
    }()
    private lazy var nameTextField: FilledTextField = {
        let view = FilledTextField(frame: .zero)
        view.delegate = self
        view.textField.keyboardType = .emailAddress
        view.iconImageView.image = UIImage(named: "account")
        view.defaultPlaceholderText = "User name"
        return view
    }()
    private lazy var passwordTextField: FilledTextField = {
        let view = FilledTextField(frame: .zero)
        view.delegate = self
        view.textField.isSecureTextEntry = true
        view.textField.keyboardType = .emailAddress
        view.iconImageView.image = UIImage(named: "lock")
        view.defaultPlaceholderText = "Password"
        return view
    }()
    private lazy var otpTextField: FilledTextField = {
        let view = FilledTextField(frame: .zero)
        view.delegate = self
        view.textField.keyboardType = .emailAddress
        view.iconImageView.image = UIImage(named: "lock")
        view.defaultPlaceholderText = "One Time Password"
        view.isHidden = true
        return view
    }()
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .primary_700
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitle("LOGIN", for: .normal)
        button.clipsToBounds = true
        button.isEnabled = false
        return button
    }()
    private lazy var loginWithWebButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("Login with Web", for: .normal)
        button.clipsToBounds = true
        button.rx.tap
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] _ in
                    self?.authorizeWithWeb()
                }).disposed(by: bag)
        return button
    }()
    private var activeTextField: FilledTextField? = nil


    private func bind() {
        let loginButtonTap = loginButton.rx.tap.asDriver()
        let usernameDidChanged = nameTextField.rx.textDidChange.asDriver()
        let passwordDidChanged = passwordTextField.rx.textDidChange.asDriver()
        let otpDidChanged = otpTextField.rx.textDidChange.asDriver()
        let input = LoginViewModel.Input(
                loginButtonTap: loginButtonTap,
                usernameDidChange: usernameDidChanged,
                passwordDidChange: passwordDidChanged,
                otpDidChange: otpDidChanged
        )
        let output = viewModel.transform(input: input)
        output.isLoginButtonEnabled.drive(onNext: { [weak self] isEnabled in
            self?.loginButton.isEnabled = isEnabled
            self?.loginButton.backgroundColor = isEnabled ? .secondary_main : .primary_700
        }).disposed(by: bag)
        output.isLoading.drive(onNext: { isLoading in
            isLoading ? SVProgressHUD.show() : SVProgressHUD.dismiss()
        }).disposed(by: bag)
        output.error.drive(onNext: { [weak self] error in
            if let error = error as? APIError {
                self?.presentAlert(title: "Error", message: error.message)
            } else {
                self?.presentAlert(title: "Error", message: error.localizedDescription)
            }
        }).disposed(by: bag)
        output.isNeedOtp.drive(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.otpTextField.isHidden = false
            self.logoView.snp.updateConstraints {
                $0.top.equalToSuperview().offset(80 * self.hratio)
            }
            self.loginButton.snp.remakeConstraints {
                $0.height.equalTo(48)
                $0.right.left.equalTo(self.loginWithWebButton)
                $0.top.equalTo(self.otpTextField.snp.bottom).offset(48 * self.hratio)
            }
        }).disposed(by: bag)
    }

    private let wratio = UIScreen.main.bounds.width / 375
    private let hratio = UIScreen.main.bounds.height / 667

    private func setupSubviews() {
        [nameTextField, passwordTextField, otpTextField,
         logoView, loginButton, loginWithWebButton].forEach(scrollView.addSubview)
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        logoView.snp.makeConstraints {
            $0.centerX.equalTo(nameTextField)
            $0.top.equalToSuperview().offset(130 * hratio)
            $0.width.equalTo(150 * wratio)
            $0.height.equalTo(90 * wratio)
        }
        nameTextField.snp.makeConstraints {
            $0.leading.equalTo(view.snp.leadingMargin).inset(8)
            $0.trailing.equalTo(view.snp.trailingMargin).inset(8)
            $0.top.equalTo(logoView.snp.bottom).offset(100 * hratio)
        }
        passwordTextField.snp.makeConstraints {
            $0.right.left.equalTo(nameTextField)
            $0.top.equalTo(nameTextField.snp.bottom).offset(12)
        }
        otpTextField.snp.makeConstraints {
            $0.right.left.equalTo(nameTextField)
            $0.top.equalTo(passwordTextField.snp.bottom).offset(12)
        }
        loginButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.right.left.equalTo(loginWithWebButton)
            $0.top.equalTo(passwordTextField.snp.bottom).offset(48 * hratio)
        }
        loginWithWebButton.snp.makeConstraints {
            $0.height.equalTo(36)
            $0.centerX.equalToSuperview()
            $0.leading.equalTo(view.snp.leadingMargin).inset(70 * wratio)
            $0.trailing.equalTo(view.snp.trailingMargin).inset(70 * wratio)
            $0.top.equalTo(loginButton.snp.bottom).offset(18 * hratio)
            $0.bottom.greaterThanOrEqualToSuperview().inset(12)
        }
    }
}

extension LoginViewController {
    private func authorizeWithWeb() {
        guard let url = viewModel.authorizeUrl else {
            return
        }
        let viewController = WebViewController(url: url, delegate: self)
        navigationController?.present(viewController, animated: true)
    }

    private func navigateToGist() {
        guard let navigationController = self.navigationController else { return }
        let provider = Application.shared.defaultUseCaseProvider()
        let navigator = GistNavigator(provider: provider, navigationController: navigationController)
        navigator.toRoot()
    }
}

extension LoginViewController: WebViewControllerDelegate {
    func callback(in: WebViewController, code: String) {
        viewModel.login(code: code, onSuccess: { [weak self] in
//            self?.navigateToGist()
        }, onError: { [weak self] error in
            self?.presentAlert(title: "Error", message: error)
        })
    }
}

extension LoginViewController: FilledTextFieldDelegate {
    func filledTextFieldDidBeginFocusing(_ textField: FilledTextField) {
        activeTextField = textField
    }
}

// MARK: - Keyboard Handling

extension LoginViewController {
    private func registerKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
                self,
                selector: #selector(keyboardWillShow(notification:)),
                name: UIResponder.keyboardWillShowNotification,
                object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(
                self,
                selector: #selector(keyboardWillShow(notification:)),
                name: UIResponder.keyboardWillChangeFrameNotification,
                object: nil)
        notificationCenter.addObserver(
                self,
                selector: #selector(keyboardWillHide(notification:)),
                name: UIResponder.keyboardWillHideNotification,
                object: nil)
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardDidHideNotification,
            object: nil)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                let textField = activeTextField else {
            return
        }
        let diff = textField.frame.origin.y + textField.frame.height + 16
                - (UIScreen.main.bounds.height - frame.height)
        if diff > 0 {
            scrollView.contentOffset.y = diff
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        scrollView.contentOffset.y = 0
    }
}
