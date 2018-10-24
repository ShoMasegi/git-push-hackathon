import Foundation
import Domain

final class Gist {
    let id: String
    let description: String?
    let owner: User
    let files: [String: File]
    let updatedAt: String //TODO: Date

    init(with gist: Domain.Gist) {
        id = gist.id
        description = gist.description
        owner = User(with: gist.owner)
        files = gist.files.mapValues { File(with: $0) }
        updatedAt = gist.updatedAt
    }
}

