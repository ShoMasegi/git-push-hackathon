import Foundation
import UIKit
import Domain

final class LoginNavigator {

    private let provider: NetworkUseCaseProvider
    private weak var navigationController: UINavigationController?

    init(provider: NetworkUseCaseProvider,
         navigationController: UINavigationController?) {
        self.provider = provider
        self.navigationController = navigationController
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func toRoot() {
        let viewModel = LoginViewModel(useCase: provider.makeLoginUseCase(), navigator: self)
        let viewController = LoginViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
