import UIKit

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func didTapLogoutButton()
    func viewDidLoad()


}

final class ProfileViewPresenter: NSObject, ProfileViewPresenterProtocol {

    weak var view: ProfileViewControllerProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let profileService: ProfileServiceProtocol
     private let imageService: ProfileImageServiceProtocol

     init(
         view: ProfileViewControllerProtocol? = nil,
         profileService: ProfileServiceProtocol = ProfileService.shared,
         imageService: ProfileImageServiceProtocol = ProfileImageService.shared
     ) {
         self.view = view
         self.profileService = profileService
         self.imageService = imageService
     }

    
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
        guard let profile = profileService.profile,
              let avatarUrlString = imageService.avatarURL,
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
