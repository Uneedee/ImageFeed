import UIKit

final class SplashViewController: UIViewController {
    let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage.shared.self
    deinit {
        print("⚠️ SplashViewController DEALLOCATED")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        UserDefaults.standard.removeObject(forKey: "bearerToken")

        if let token = storage.tokenKey {
            switchToTabBarController()
            fetchProfile(token: token)
            
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {

            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }

            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        print("Направление на экран аутентификации")
        vc.dismiss(animated: true)
        print("WK скрыт")
        print("Переходим к таб бару ")
        switchToTabBarController()
        
        
    }
    
    func fetchProfile(token: String) {
        print("Вызван fetchProfile ")
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [self] result in
            print("Проверка замыкания")
            print("Raw result:", result)
            UIBlockingProgressHUD.dismiss()
            print("Проверка weak self")
//            guard let self = self else {
//                print("self is nil!") // Проблема тут
//                return }
            switch result {
            case .success(let profile):
                print("Попытка загрузки изображения")
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                switchToTabBarController()
            case .failure(let error):
                print("Ошибка получения профиля: \(error)")
            }

        }
        
        
    }
    
}
