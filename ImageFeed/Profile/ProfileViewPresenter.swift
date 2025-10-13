import UIKit

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func didTapLogoutButton()
    func viewDidLoad()


}

final class ProfileViewPresenter: NSObject, ProfileViewPresenterProtocol {

    weak var view: ProfileViewControllerProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?

    
    func viewDidLoad() {
        subscribeToProfileImageChanges()
        updateProfile()

    }
    private func subscribeToProfileImageChanges() {
        if profileImageServiceObserver != nil { return }
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main)
        { [weak self] _ in
            guard let self = self else { return }
            updateProfile()
        }}
    
    func updateProfile() {
        guard let profile = ProfileService.shared.profile,
              let avatarUrlString = ProfileImageService.shared.avatarURL,
              let avatarURL = URL(string: avatarUrlString) else { return }
        view?.updateProfileDetails(with: profile)
        view?.updateAvatar(url: avatarURL)
    }

    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    @objc func didTapLogoutButton() {
        view?.showLogoutAlert()

    }
}
