import Foundation
import Moya
import RxSwift

public struct Response<T> {
    public let data: T

    public init(data: T) {
        self.data = data
    }
}

extension Response {
    init() { fatalError() }
}