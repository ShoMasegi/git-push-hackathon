import Foundation

public struct ErrorResponse: Decodable {
    public let message: String?
    public init(message: String?) {
        self.message = message
    }
}

extension ErrorResponse {
    init() { fatalError() }
}