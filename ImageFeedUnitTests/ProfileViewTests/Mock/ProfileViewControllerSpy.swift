@testable import ImageFeed
import XCTest

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?

    var showLogoutAlertCalled = false
    var updateProfileDetailsCalled = false
    var updateAvatarCalled = false

    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }

    func updateProfileDetails(with profile: Profile) {
        updateProfileDetailsCalled = true
    }

    func updateAvatar(url: URL) {
        updateAvatarCalled = true
    }
}



