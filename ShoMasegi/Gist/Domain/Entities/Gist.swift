import Foundation

public struct Gist: Decodable {
    public let id: String
    public let description: String?
    public let owner: User
    public let files: [String: File]
    public let updatedAt: String //TODO: Date
}
