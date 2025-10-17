@testable import ImageFeed
import XCTest

final class ProfileImageServiceSpy: ProfileImageServiceProtocol {
    var avatarURL: String? = "https://example.com/avatar.jpg"
    static var didChangeNotification = Notification.Name("TestDidChange")
    func clearData() { }
}
