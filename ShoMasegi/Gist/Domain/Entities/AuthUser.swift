import Foundation

public struct AuthUser: Codable {
    public let id: Int64
    public let login: String
    public let avatarUrl: URL
}
