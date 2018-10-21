import Foundation
import Domain
import Moya
import RxSwift
import Library

public final class UserUseCase: Domain.UserUseCase {
    private let network: Networking

    public init(network: Networking) {
        self.network = network
    }

    public func user() -> Observable<Domain.Response<AuthUser>> {
        return network.request(.user())
                .map(to: Domain.AuthUser.self)
    }
}
