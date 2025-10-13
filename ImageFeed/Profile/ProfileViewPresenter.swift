import UIKit

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func didTapLogoutButton()
    func viewDidLoad()


}

final class ProfileViewPresenter: NSObject, ProfileViewPresenterProtocol {

    weak var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        guard let profile = ProfileService.shared.profile,
              let avatarUrlString = ProfileImageService.shared.avatarURL,
              let avatarURL = URL(string: avatarUrlString) else { return }
        view?.updateProfileDetails(with: profile)
        view?.updateAvatar(url: avatarURL)

    }
    
    

    
    @objc func didTapLogoutButton() {
        view?.showLogoutAlert()

    }
}
