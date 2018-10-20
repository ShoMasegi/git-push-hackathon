import Foundation

public final class Credentials {

    private init() {}

    public static func basic(userName: String, password: String) -> String {
        let usernameAndPassword = String(format: "%@:%@", userName, password).data(using: String.Encoding.utf8)
        guard let encoded = usernameAndPassword?.base64EncodedString() else {
            fatalError("failed encode.")
        }
        return "Basic \(encoded)"
    }
}

