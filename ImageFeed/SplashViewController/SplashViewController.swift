import UIKit
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage.shared.self
    
    deinit {
        print("⚠️ SplashViewController DEALLOCATED")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupImageView()
        setupVCAttributes()
//        KeychainWrapper.standard.removeObject(forKey: "bearerToken")
//        UserDefaults.standard.removeObject(forKey: "bearerToken")
        if let token = storage.tokenKey {
            switchToTabBarController()
            fetchProfile(token: token)
            
        } else {
            presentAuthViewController()
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
    
    func setupImageView() {
        let image = UIImage(named: "Vector")
        let imageView = UIImageView(image: image)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 78).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 75).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        
        
    }
    
    func setupVCAttributes() {
        view.backgroundColor = .ypBlack
    }
    
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Не удалось найти AuthViewController по идентификатору")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        switchToTabBarController()
        
        
    }
    
    func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [self] result in
            UIBlockingProgressHUD.dismiss()
//            guard let self = self else {
//                print("self is nil!")
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
