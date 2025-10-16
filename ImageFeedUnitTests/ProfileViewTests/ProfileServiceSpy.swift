@testable import ImageFeed
import XCTest

final class ProfileServiceSpy: ProfileServiceProtocol {
    var profile: Profile? = Profile(
        username: "user",
        name: "Test Name",
        loginName: "@test",
        bio: "Hello"
    )

    var clearDataCalled = false
    func clearData() { clearDataCalled = true }
}
