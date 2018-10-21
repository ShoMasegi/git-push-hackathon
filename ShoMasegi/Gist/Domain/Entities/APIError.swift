import Foundation

public enum APIError: Error {
    case server(statusCode: Int, message: String?)
    case semantic(message: String?)
    public var message: String {
        switch self {
        case .server(let statusCode, let message):
            if let message = message {
                return message
            } else {
                return "status code: \(statusCode)"
            }
        case .semantic(let message):
            return message ?? ""
        }
    }
}