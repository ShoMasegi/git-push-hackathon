import Foundation
import Domain
import Moya
import RxSwift
import Library

public final class LoginUseCase: Domain.LoginUseCase {
    private let network: Networking

    public init(network: Networking) {
        self.network = network
    }

    public func login(username: String, password: String, otp: String?) -> Observable<Domain.Response<Domain.BasicAuthToken>> {
        return network.request(.login(username: username, password: password, otp: otp))
                .map(to: Domain.BasicAuthToken.self)
    }
}
