import Foundation
import RxSwift

public protocol LoginUseCase {
    func login(username: String, password: String, otp: String?) -> Observable<Response<BasicAuthToken>>
    func login(code: String) -> Observable<Response<AuthToken>>
}
