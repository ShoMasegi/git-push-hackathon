import Foundation
import RxSwift

public protocol UserUseCase {
    func user() -> Observable<Response<AuthUser>>
}
