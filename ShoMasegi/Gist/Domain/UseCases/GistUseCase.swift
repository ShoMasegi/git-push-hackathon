import Foundation
import RxSwift

public protocol GistUseCase {
    func gists(page: Int) -> Observable<Response<[Gist]>>
    func publicGists(page: Int) -> Observable<Response<[Gist]>>
}
