import UIKit

final class SplashViewController: UIViewController {
    let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    let storage = OAuth2TokenStorage.shared.self
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if storage.tokenKey != nil {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
            // Пользователь не авторизован
            // ...дальнейшие действия...
        }
    }
    private func switchToTabBarController() {
        // Получаем экземпляр `window` приложения
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        // Создаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
           
        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Проверим, что переходим на авторизацию
        if segue.identifier == showAuthenticationScreenSegueIdentifier {

            // Доберёмся до первого контроллера в навигации
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }

            // Установим делегатом контроллера наш SplashViewController
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        switchToTabBarController()
        // TODO Добавьте переход к галерее
    }
}
