import Foundation
import RxSwift
import Moya
import Domain

struct Response<T: Decodable> {
    let data: T
}

struct ErrorResponse: Decodable {
    let message: String?
}

extension Domain.Response where T: Decodable {

    init(response: Moya.Response) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let responseEntity: T = try decoder.decode(T.self, from: response.data)
        self.init(data: responseEntity)
    }
}

extension Domain.ErrorResponse {

    init(response: Moya.Response) throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let responseEntity: ErrorResponse = try decoder.decode(ErrorResponse.self, from: response.data)
        self.init(message: responseEntity.message)
    }
}

extension ObservableType where E == Moya.Response {

    public func map<T: Decodable>(to: T.Type) -> Observable<Domain.Response<T>> {
        return flatMap { response -> Observable<Domain.Response<T>> in
            do {
                let res = try Domain.Response<T>.init(response: response)
                return Observable.just(res)
            } catch let error {
                return Observable.error(error)
            }
        }
    }

    public func filterAPIError() -> Observable<E> {
        return flatMap({ response -> Observable<E> in
            switch response.statusCode {
            case 200...299:
                return Observable.just(response)
            default:
                do {
                    let res = try Domain.ErrorResponse.init(response: response)
                    return Observable.error(APIError.server(statusCode: response.statusCode, message: res.message))
                } catch let error {
                    return Observable.error(error)
                }
            }
        })
    }
}
