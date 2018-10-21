import Moya
import RxMoya
import RxSwift
import Domain
import Library

public final class Provider<Target> where Target: Moya.TargetType {
    private let provider: MoyaProvider<Target>
    init(endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider<Target>.defaultEndpointMapping,
         requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider<Target>.neverStub,
         manager: Manager = MoyaProvider<Target>.defaultAlamofireManager(),
         plugins: [PluginType] = [],
         trackInflights: Bool = false) {
        provider = MoyaProvider(
                endpointClosure: endpointClosure,
                requestClosure: requestClosure,
                stubClosure: stubClosure,
                manager: manager,
                plugins: plugins,
                trackInflights: trackInflights
        )
    }

    func request(_ target: Target) -> Observable<Moya.Response> {
        return provider.rx.request(target).asObservable()
    }
}

public protocol NetworkingType {
    associatedtype T: TargetType
    var provider: Provider<T> { get }
}

public struct Networking: NetworkingType {
    public typealias T = GAPI
    public let provider: Provider<T>
    let responseFilterClosure: ((Int) -> Bool)?

    init(provider: Provider<T>, responseFilterClosure: ((Int) -> Bool)? = nil) {
        self.provider = provider
        self.responseFilterClosure = responseFilterClosure
    }
}

extension Networking {
    public func request(_ target: GAPI) -> Observable<Moya.Response> {
        return provider.request(target)
                .filter({ response -> Bool in
                    self.responseFilterClosure?(response.statusCode) ?? true
                })
    }
}

extension NetworkingType {
    public static func newDefaultNetworking(responseFilterClosure: ((Int) -> Bool)? = nil) -> Networking {
        return Networking(provider: newProvider(plugins), responseFilterClosure: responseFilterClosure)
    }

    static var plugins: [PluginType] {
        return [
            NetworkLoggerPlugin(verbose: true)
        ]
    }

    static func requestClosure() -> MoyaProvider<T>.RequestClosure {
        return { endpoint, closure in
            do {
                var request = try endpoint.urlRequest()
                request.httpShouldHandleCookies = false
                if let token = AppEnvironment.current.token {
                    let authHeader = "token " + token
                    request.addValue(authHeader, forHTTPHeaderField: "Authorization")
                }
                if let otp = AppEnvironment.current.otp {
                    request.addValue(otp, forHTTPHeaderField: "X-GitHub-OTP")
                }
                closure(.success(request))
            } catch let error {
                closure(.failure(MoyaError.underlying(error, nil)))
            }
        }
    }

    static func endpointClosure(statusCode: Int, data: Data) -> MoyaProvider<T>.EndpointClosure {
        return { target in
            let url = target.baseURL.appendingPathComponent(target.path).absoluteString
            let sampleResponse: Endpoint.SampleResponseClosure = {
                return .networkResponse(statusCode, data)
            }
            return Endpoint(url: url, sampleResponseClosure: sampleResponse, method: target.method, task: target.task, httpHeaderFields: target.headers)
        }
    }
}

private func newProvider<T>(_ plugins: [PluginType]) -> Provider<T> {
    return Provider<T>(
            requestClosure: Networking.requestClosure(),
            stubClosure: MoyaProvider.neverStub,
            plugins: plugins
    )
}

extension NetworkingType {
    public static func newStubNetworking() -> Networking {
        return Networking(
                provider: Provider(
                        requestClosure: Networking.requestClosure(),
                        stubClosure: MoyaProvider.immediatelyStub
                )
        )
    }

    public static func newTestNetworking(statusCode: Int, data: Data) -> Networking {
        return Networking(
                provider: Provider(
                        endpointClosure: Networking.endpointClosure(statusCode: statusCode, data: data),
                        stubClosure: MoyaProvider.immediatelyStub
                )
        )
    }
}
