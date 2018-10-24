import UIKit
import Domain

final class GistNavigator {

    private let provider: NetworkUseCaseProvider
    private weak var navigationController: UINavigationController?

    init(provider: NetworkUseCaseProvider,
         navigationController: UINavigationController?) {
        self.provider = provider
        self.navigationController = navigationController
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func toRoot() {
        let viewModel = GistViewModel(useCase: provider.makeGistUseCase(), navigator: self)
        let viewController = GistViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: false)
    }

    func toDetail(gist: Gist) {

    }
}
