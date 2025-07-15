import UIKit

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    private let storage: UserDefaults = .standard
    let bearerToken = "bearerToken"
    var tokenKey: String? {
        get { storage.string(forKey: bearerToken) }
        set { storage.set(newValue, forKey: bearerToken)}
    }
}
