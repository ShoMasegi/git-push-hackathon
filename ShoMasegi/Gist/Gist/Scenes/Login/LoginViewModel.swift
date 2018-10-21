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

    private var username: String? = "xxxx"
    private var password: String? = "xxxx"
    private var otp: String?
}

extension LoginViewModel {
    struct Input {
    }

    struct Output {
    }
}

extension LoginViewModel {
    func transform(input _: Input) -> Output {
        return Output()
    }

    func login(onSuccess: @escaping (BasicAuthToken) -> Void, onError: @escaping (String) -> Void) {
        guard let username = username, let password = password else {
            return
        }
        useCase.login(username: username, password: password, otp: otp)
                .map { $0.data }
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { authToken in
                    onSuccess(authToken)
                    AppEnvironment.replaceCurrentEnvironment(token: authToken.token)
                }, onError: { error in
                    if let apiError = error as? APIError {
                        onError(apiError.message)
                    } else {
                        onError(error.localizedDescription)
                    }
                })
                .disposed(by: bag)
    }
}
