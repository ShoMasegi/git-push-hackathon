import Foundation

public struct AuthToken: Decodable {
    public let accessToken: String
}

public struct AuthParameter: Encodable {
    public let clientId: String
    public let clientSecret: String
    public var code: String?

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case code
    }
}

extension AuthParameter {
    public init(
            code: String? = nil
    ) {
        guard let urls = Bundle.main.path(forResource: "Client", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: urls),
              let clientId = plist["id"] as? String,
              let clientSecret = plist["secret"] as? String else {

            fatalError("failed creating AuthParameter.")
        }
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.code = code
    }
}
