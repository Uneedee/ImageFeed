import Foundation
import WebKit

final class ProfileLogoutService {
   static let shared = ProfileLogoutService()
  
   private init() { }

   func logout() {
      cleanCookies()
       ProfileService.shared.clearData()
       ProfileImageService.shared.clearData()
       ImagesListService.shared.clearData()
       OAuth2TokenStorage.shared.tokenKey = nil

       
       DispatchQueue.main.async {
           self.resetToAuthScreen()
       }
       
   }
    
    private func resetToAuthScreen() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }
        sceneDelegate.resetToAuthScreen()
    }

   private func cleanCookies() {
      HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
      WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
         records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
         }
      }
   }
}
    
