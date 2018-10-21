import Foundation
import Domain

final class AuthUser: Codable {
    let id: Int64
    let login: String
    let avatarUrl: URL

    init(with user: Domain.AuthUser) {
        id = user.id
        login = user.login
        avatarUrl = user.avatarUrl
    }
}
