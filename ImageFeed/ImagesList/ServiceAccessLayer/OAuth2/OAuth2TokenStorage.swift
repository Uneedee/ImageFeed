import UIKit

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    let bearerToken = "bearerToken"
    private let storage: UserDefaults = .standard
    var tokenKey: String? {
        get { storage.string(forKey: bearerToken) }
        set { storage.set(newValue, forKey: bearerToken)}
    }
    private init() {}
}
