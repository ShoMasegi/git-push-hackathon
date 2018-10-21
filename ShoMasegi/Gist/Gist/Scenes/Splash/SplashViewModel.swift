import Foundation
import Domain
import Library
import RxCocoa
import RxSwift

final class SplashViewModel: ViewModelType {

    private let useCase: UserUseCase
    private let bag = DisposeBag()

    init(useCase: UserUseCase) {
        self.useCase = useCase
    }
}

extension SplashViewModel {
    struct Input {
    }

    struct Output {
    }
}

extension SplashViewModel {
    func transform(input _: Input) -> Output {
        return Output()
    }

    func user(onSuccess: @escaping (AuthUser) -> Void, onError: ((String) -> Void)?) {
        useCase.user()
                .map { AuthUser(with: $0.data) }
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { user in
                    onSuccess(user)
                }, onError: { error in
                    if let apiError = error as? APIError {
                        onError?(apiError.message)
                    } else {
                        onError?(error.localizedDescription)
                    }
                })
                .disposed(by: bag)
    }
}
