import Foundation

public struct BasicAuthToken: Decodable {
    public let token: String
}

public struct BasicAuthParameter: Encodable {
    public let clientId: String
    public let clientSecret: String
    public let scopes: [Scope]
    public let note: String = "com.sho.masegi.gist"
    public let noteUrl: String? // TODO: implement
    public let fingerprint: String?

}

extension BasicAuthParameter {
    public init(
            scopes: [Scope] = [.gist, .user, .repo],
            noteUrl: String? = nil,
            fingerprint: String? = nil
    ) {
        guard let urls = Bundle.main.path(forResource: "Client", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: urls),
              let clientId = plist["id"] as? String,
              let clientSecret = plist["secret"] as? String else {

            fatalError("failed creating AuthModel.")
        }
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.scopes = scopes
        self.noteUrl = noteUrl
        self.fingerprint = fingerprint
    }
}
