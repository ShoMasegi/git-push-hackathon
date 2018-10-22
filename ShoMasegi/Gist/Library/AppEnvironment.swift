import Domain
import Foundation
import KeychainAccess

public struct AppEnvironment {
    public static let environmentStorageKey = "sho.masegi.gist.AppEnvironment.current"
    public static let tokenStorageKey = "sho.masegi.gist.AppEnvironment.token"

    private static var stack: [Environment] = [Environment()]
    public static var current: Environment {
        return stack.last ?? Environment()
    }

    public static func pushEnvironment(_ env: Environment) {
        saveEnvironment(environment: env,
                userDefaults: env.userDefaults,
                keychain: env.keychain)
        stack.append(env)
    }

    @discardableResult
    public static func popEnvironment() -> Environment? {
        let last = stack.popLast()
        let next = current
        saveEnvironment(environment: next,
                userDefaults: next.userDefaults,
                keychain: next.keychain)
        return last
    }

    public static func pushEnvironment(
            token: String? = AppEnvironment.current.token,
            userDefaults: KeyValuesStoreType = AppEnvironment.current.userDefaults,
            keychain: Keychain = AppEnvironment.current.keychain
    ) {
        pushEnvironment(
                Environment(
                        token: token,
                        userDefaults: userDefaults,
                        keychain: keychain
                )
        )
    }

    public static func replaceCurrentEnvironment(_ env: Environment) {
        pushEnvironment(env)
        stack.remove(at: stack.count - 2)
    }


    public static func replaceCurrentEnvironment(
            token: String? = AppEnvironment.current.token,
            userDefaults: KeyValuesStoreType = AppEnvironment.current.userDefaults,
            keychain: Keychain = AppEnvironment.current.keychain
    ) {
        replaceCurrentEnvironment(
                Environment(
                        token: token,
                        userDefaults: userDefaults,
                        keychain: keychain
                )
        )
    }

    public static func fromStorage(userDefaults: KeyValuesStoreType, keychain: Keychain) -> Environment {
        let data = userDefaults.dictionary(forKey: environmentStorageKey) ?? [:]
        let token: String? = keychain[tokenStorageKey]
        return Environment(token: token)
    }

    public static func saveEnvironment(
            environment env: Environment = AppEnvironment.current,
            userDefaults: KeyValuesStoreType,
            keychain: Keychain
    ) {
        var data: [String: Any] = [:]
        let encoder = JSONEncoder()
        userDefaults.set(data, forKey: environmentStorageKey)
        keychain[tokenStorageKey] = env.token
    }

    public static func clear() {
        stack.removeAll()
    }
}

public struct Environment {
    public let token: String?
    public let userDefaults: KeyValuesStoreType
    public let keychain: Keychain
    public init(
            token: String? = nil,
            userDefaults: KeyValuesStoreType = UserDefaults.standard,
            keychain: Keychain = Keychain()
    ) {
        self.token = token
        self.userDefaults = userDefaults
        self.keychain = keychain
    }
}
