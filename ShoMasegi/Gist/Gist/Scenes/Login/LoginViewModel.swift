import Foundation
import Domain
import Library
import RxCocoa
import RxSwift

final class LoginViewModel: ViewModelType {
    private let useCase: LoginUseCase
    private let navigator: LoginNavigator
    private let bag = DisposeBag()

    init(useCase: LoginUseCase, navigator: LoginNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }

    private var username: String?
    private var password: String?
    private var otp: String?
}

extension LoginViewModel {
    struct Input {
        let loginButtonTap: Driver<Void>
        let loginWithWebButtonTap: Driver<Void>
        let usernameDidChange: Driver<String?>
        let passwordDidChange: Driver<String?>
        let otpDidChange: Driver<String?>
    }

    struct Output {
        let isLoginButtonEnabled: Driver<Bool>
        let isLoading: Driver<Bool>
        let error: Driver<Error>
        let isNeedOtp: Driver<Void>
    }
}

extension LoginViewModel {
    func transform(input: Input) -> Output {
        let loadingActivityIndicator = ActivityIndicator()
        let loading = loadingActivityIndicator.asDriver()
        let errorTracker = ErrorTracker()
        let errors = errorTracker.asDriver()
        let isLoginButtonEnabled =
                Driver.combineLatest(input.usernameDidChange, input.passwordDidChange) { (username, password) -> Bool in
                    return !(username ?? "").isEmpty && !(password ?? "").isEmpty
                }
        // TODO: ここら辺なんとかしたい
        input.usernameDidChange.drive(onNext: { self.username = $0})
                .disposed(by: bag)
        input.passwordDidChange.drive(onNext: { self.password = $0})
                .disposed(by: bag)
        input.otpDidChange.drive(onNext: { self.otp = $0})
                .disposed(by: bag)
        input.loginButtonTap
                .withLatestFrom(loading)
                .filter { !$0 }
                .drive(onNext: { _ in
                    self.login(activityIndicator: loadingActivityIndicator, errorTracker: errorTracker)
                }).disposed(by: bag)
        let isNeedOtp = errors.filter { error -> Bool in
            if let apiError = error as? APIError {
                switch apiError {
                case .server(let statusCode, let message):
                    return statusCode == 401 && (message ?? "").contains("two-factor")
                case .semantic:
                    return false
                }
            } else {
                return false
            }
        }.mapToVoid().asDriver()
        return Output(
                isLoginButtonEnabled: isLoginButtonEnabled,
                isLoading: loading,
                error: errors,
                isNeedOtp: isNeedOtp
        )
    }

    private func login(
            activityIndicator: ActivityIndicator,
            errorTracker: ErrorTracker
    ) {
        guard let username = username, let password = password else {
            return
        }
        return useCase.login(username: username, password: password, otp: otp)
                .trackActivity(activityIndicator)
                .trackError(errorTracker)
                .map { $0.data }
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { accessToken in
                    AppEnvironment.replaceCurrentEnvironment(token: accessToken.token)
                }).disposed(by: bag)
    }
}
