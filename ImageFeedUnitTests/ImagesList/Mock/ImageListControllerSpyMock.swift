@testable import ImageFeed
import UIKit

final class ImageListControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImageListViewPresenterProtocol?
    var insertRowsCalled = false
    var reloadRowCalled = false
    var showLikeErrorAlertCalled = false


    func insertRows(indexPath: [IndexPath]) {
        insertRowsCalled = true
    }

    func reloadRow(at indexPath: IndexPath) {
        reloadRowCalled = true
    }

    func showLikeErrorAlert() {
        showLikeErrorAlertCalled = true
    }
}

