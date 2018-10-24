import Foundation
import Moya
import RxSwift
import Domain

public final class GistUseCase: Domain.GistUseCase {
    private let network: Networking

    public init(network: Networking) {
        self.network = network
    }

    public func gists(page: Int) -> Observable<Domain.Response<[Domain.Gist]>> {
        return network.request(.gist(page: page))
                .filterAPIError()
                .map(to: [Domain.Gist].self)
    }

    public func publicGists(page: Int) -> Observable<Domain.Response<[Domain.Gist]>> {
        return network.request(.publicGist(page: page))
                .filterAPIError()
                .map(to: [Domain.Gist].self)
    }
}
