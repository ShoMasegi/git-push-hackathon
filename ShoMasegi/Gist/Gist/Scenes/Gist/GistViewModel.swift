import Foundation
import RxCocoa
import RxSwift
import Library
import Domain

final class GistViewModel: ViewModelType {

    private let useCase: GistUseCase
    private let navigator: GistNavigator
    private let bag = DisposeBag()
    init(useCase: GistUseCase, navigator: GistNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }

    private let elements = Variable<[Gist]>([])
    private let hasNext = Variable<Bool>(true)
    private let lastLoadedPage = Variable<Int>(1)
}

extension GistViewModel {
    struct Input {
        let initTrigger: Driver<Void>
        let refreshTrigger: Driver<Void>
        let loadNextPageTrigger: Driver<Void>
        let modelSelected: Driver<Gist>
    }

    struct Output {
        let refreshing: Driver<Bool>
        let loading: Driver<Bool>
        let gists: Driver<[Gist]>
        let isNavigated: Driver<Bool>
        let error: Driver<Error>
    }
}

extension GistViewModel {
    func transform(input: Input) -> Output {
        let refreshingActivityIndicator = ActivityIndicator()
        let loadingActivityIndicator = ActivityIndicator()
        let refreshing = refreshingActivityIndicator.asDriver()
        let loading = loadingActivityIndicator.asDriver()
        let errorTracker = ErrorTracker()
        let errors = errorTracker.asDriver()
        let refreshResponse = Driver.merge(input.initTrigger, input.refreshTrigger)
                .withLatestFrom(refreshing)
                .filter { !$0 }
                .do(onNext: { _ in
                    self.elements.value = []
                    self.lastLoadedPage.value = 1
                    self.hasNext.value = true
                })
                .flatMapLatest { (_) -> Driver<[Gist]> in
                    return self.request(
                            page: self.lastLoadedPage.value,
                            activityIndicator: refreshingActivityIndicator,
                            errorTracker: errorTracker
                    )
                }
        let nextPageResponse = input.loadNextPageTrigger
                .withLatestFrom(loading)
                .filter { !$0 }
                .withLatestFrom(hasNext.asDriver())
                .filter { $0 }
                .withLatestFrom(lastLoadedPage.asDriver())
                .flatMap { lastLoadedPage -> Driver<[Gist]> in
                    return self.request(page: lastLoadedPage + 1,
                            activityIndicator: loadingActivityIndicator,
                            errorTracker: errorTracker)
                }
        let isNavigated = input.modelSelected
                .do(onNext: { model in
                    self.navigator.toDetail(gist: model)
                })
                .map { _ in true }
        Driver
                .merge(refreshResponse, nextPageResponse)
                .drive(onNext: {
                    self.elements.value.append(contentsOf: $0)
                }).disposed(by: bag)

        return Output(refreshing: refreshing,
                loading: loading,
                gists: elements.asDriver(),
                isNavigated: isNavigated,
                error: errors)
    }

    private func request(
            page: Int,
            activityIndicator: ActivityIndicator,
            errorTracker: ErrorTracker
    ) -> Driver<[Gist]> {
        return useCase.gists(page: page)
                .trackActivity(activityIndicator)
                .trackError(errorTracker)
                .do(onNext: { gists in
                    if gists.data.isEmpty {
                        self.hasNext.value = false
                    } else {
                        self.lastLoadedPage.value += 1
                    }
                })
                .map { $0.data.map { Gist(with: $0) } }
                .catchError({ _ -> Observable<[Gist]> in
                    self.hasNext.value = false
                    return Observable.just([])
                })
                .asDriver(onErrorJustReturn: [])
    }
}
