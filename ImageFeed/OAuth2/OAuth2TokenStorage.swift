import UIKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let bearerToken = "bearerToken"
    private let storage: UserDefaults = .standard
    var tokenKey: String? {
        get { return KeychainWrapper.standard.string(forKey: bearerToken) }
        set { if let token = newValue {
            KeychainWrapper.standard.set(token, forKey: bearerToken)
        } else {
            KeychainWrapper.standard.removeObject(forKey: bearerToken)
        }
        }
    }
    
    func clearData() {
        tokenKey = nil
    }
    private init() {}
}
