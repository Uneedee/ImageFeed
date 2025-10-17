@testable import ImageFeed
import XCTest

final class ProfileViewPresenterTests: XCTestCase {

    func testDidTapLogoutButton_ShowsAlert() {
        // given
        let view = ProfileViewControllerSpy()
        let sut = ProfileViewPresenter(view: view,
                                       profileService: ProfileServiceSpy(),
                                       imageService: ProfileImageServiceSpy())
        view.presenter = sut

        // when
        sut.didTapLogoutButton()

        // then
        XCTAssertTrue(view.showLogoutAlertCalled, "Ожидалось, что showLogoutAlert будет вызван")
    }

    func testViewDidLoad_UpdatesProfileAndAvatar() {
        // given
        let view = ProfileViewControllerSpy()
        let profileService = ProfileServiceSpy()
        let imageService = ProfileImageServiceSpy()
        let sut = ProfileViewPresenter(view: view,
                                       profileService: profileService,
                                       imageService: imageService)

        // when
        sut.viewDidLoad()

        // then
        XCTAssertTrue(view.updateProfileDetailsCalled, "updateProfileDetails() должен быть вызван")
        XCTAssertTrue(view.updateAvatarCalled, "updateAvatar() должен быть вызван")
    }
}
