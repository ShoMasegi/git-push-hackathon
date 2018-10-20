import Domain
import Foundation

public struct AppEnvironment {
    public static let environmentStorageKey = "com.sho.masegi.Gist.current"
    public static let tokenStorageKey = "com.sho.masegi.Gist.token"

    private static var stack: [Environment] = [Environment()]
    public static var current: Environment {
        return stack.last ?? Environment()
    }

    public static func pushEnvironment(_ env: Environment) {
        saveEnvironment(environment: env, userDefaults: env.userDefaults)
        stack.append(env)
    }

    @discardableResult
    public static func popEnvironment() -> Environment? {
        let last = stack.popLast()
        let next = current
        saveEnvironment(environment: next, userDefaults: next.userDefaults)
        return last
    }

    public static func pushEnvironment(
            token: String? = AppEnvironment.current.token,
            userDefaults: KeyValuesStoreType = AppEnvironment.current.userDefaults
    ) {
        pushEnvironment(
                Environment(
                        token: token,
                        userDefaults: userDefaults
                )
        )
    }

    public static func replaceCurrentEnvironment(_ env: Environment) {
        pushEnvironment(env)
        stack.remove(at: stack.count - 2)
    }


    public static func replaceCurrentEnvironment(
            token: String? = AppEnvironment.current.token,
            userDefaults: KeyValuesStoreType = AppEnvironment.current.userDefaults
    ) {
        replaceCurrentEnvironment(
                Environment(
                        token: token,
                        userDefaults: userDefaults
                )
        )
    }

    public static func fromStorage(userDefaults: KeyValuesStoreType) -> Environment {
        let data = userDefaults.dictionary(forKey: environmentStorageKey) ?? [:]
        let token: String? = nil // TODO: implement
        return Environment(token: token)
    }

    public static func saveEnvironment(
            environment env: Environment = AppEnvironment.current,
            userDefaults: KeyValuesStoreType
    ) {
        var data: [String: Any] = [:]
        let encoder = JSONEncoder()
        userDefaults.set(data, forKey: environmentStorageKey)
    }

    public static func clear() {
        stack.removeAll()
    }
}

public struct Environment {
    public let token: String?
    public let otp: String?
    public let userDefaults: KeyValuesStoreType
    public init(
            token: String? = nil,
            otp: String? = nil,
            userDefaults: KeyValuesStoreType = UserDefaults.standard
    ) {
        self.token = token
        self.otp = otp
        self.userDefaults = userDefaults
    }
}
