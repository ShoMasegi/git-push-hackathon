import Foundation
import Domain

final class File {
    let filename: String
    let type: String
    let language: String?
    let rawUrl: URL
    let size: Int64

    init(with file: Domain.File) {
        filename = file.filename
        type = file.type
        language = file.language
        rawUrl = file.rawUrl
        size = file.size
    }
}