import Moya
import Alamofire
import Domain
import Library

public enum GAPI {
    case login(username: String, password: String, otp: String?)
    case user()
}

extension GAPI: TargetType {
    private struct Environment {
        static var urlString: String {
            return "https://api.github.com/"
        }
    }

    public var baseURL: URL {
        guard let url = URL(string: Environment.urlString) else {
            fatalError("baseURL could not be configured.")
        }
        return url
    }

    public var fullUrl: String {
        switch self {
        default: return baseURL.absoluteString + path
        }
    }

    public var path: String {
        switch self {
        case .login:
            return "authorizations"
        case .user:
            return "user"
        default: return ""
        }
    }

    public var method: Moya.Method {
        switch self {
        case .login:
            return .post
        default: return .get
        }
    }

    public var sampleData: Data {
        fatalError("sampleData has not been implemented")
    }

    public var task: Moya.Task {
        switch self {
        case .login:
            return .requestJSONEncodable(AuthModel())
        default: return .requestPlain
        }
    }
    public var headers: [String: String]? {
        switch self {
        case .login(let username, let password, let otp):
            if let onetime = otp {
                return [
                    "Authorization": Credentials.basic(userName: username, password: password),
                    "X-GitHub-OTP": onetime
                ]
            } else {
                return ["Authorization": Credentials.basic(userName: username, password: password)]
            }
        default: return [:]
        }
    }
}
