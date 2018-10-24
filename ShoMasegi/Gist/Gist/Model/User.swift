import Foundation
import Domain

final class User {
    let id: Int64
    let login: String
    let url: URL
    let avatarUrl: URL

    init(with user: Domain.User) {
        id = user.id
        login = user.login
        url = user.url
        avatarUrl = user.avatarUrl
    }
}
