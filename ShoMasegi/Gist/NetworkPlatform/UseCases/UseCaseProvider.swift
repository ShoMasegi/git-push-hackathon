import Foundation
import Domain

public final class UseCaseProvider: Domain.NetworkUseCaseProvider {
    private let networkProvider: Networking

    public init(networking: Networking) {
        networkProvider = networking
    }

    public init() {
        networkProvider = Networking.newDefaultNetworking()
    }

    public func makeLoginUseCase() -> Domain.LoginUseCase {
        return LoginUseCase(network: networkProvider)
    }

    public func makeUserUserCase() -> Domain.UserUseCase {
        return UserUseCase(network: networkProvider)
    }
}
