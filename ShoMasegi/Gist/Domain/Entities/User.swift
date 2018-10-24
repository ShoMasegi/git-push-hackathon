import Foundation

public struct User: Decodable {
    public let id: Int64
    public let login: String
    public let url: URL
    public let avatarUrl: URL
}
