import Moya
import Alamofire
import Domain
import Library

public enum GAPI {
    case login(username: String, password: String, otp: String?)
    case loginweb(code: String)
    case user()
    case gist(page: Int)
    case publicGist(page: Int)
}

extension GAPI: TargetType {
    private struct Environment {
        static var apiUrlString: String {
            return "https://api.github.com/"
        }
        static var basicUrlString: String {
            return "https://github.com/"
        }
    }

    public var baseURL: URL {
        let string: String
            switch self {
            case .loginweb: string = Environment.basicUrlString
            default:  string = Environment.apiUrlString
        }
        guard let url = URL(string: string) else {
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
        case .loginweb:
            return "login/oauth/access_token"
        case .user:
            return "user"
        case .gist:
            return "gists"
        case .publicGist:
            return "gists/public"
        default: return ""
        }
    }

    public var method: Moya.Method {
        switch self {
        case .login, .loginweb:
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
            return .requestJSONEncodable(BasicAuthParameter())
        case .loginweb(let code):
            return .requestJSONEncodable(AuthParameter(code: code))
        case .gist(let page), .publicGist(let page):
            return .requestParameters(parameters: ["page": page], encoding: URLEncoding.default)
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
        case .loginweb: return ["ACCEPT": "application/json"]
        default: return [:]
        }
    }
}
