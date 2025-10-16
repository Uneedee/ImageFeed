@testable import ImageFeed
import XCTest
import UIKit

final class ImageListControllerTests: XCTestCase {
    
    func testViewControllerCallsPresenterOnViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: ImagesListViewController.self))
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController

        let presenterSpy = ImageListPresenterSpy()
        viewController.configure(presenterSpy)
        // when
        _ = viewController.view // подгружает @IBOutlet
            viewController.viewDidLoad()
        
        // then
        XCTAssertTrue(presenterSpy.viewDidLoadIsCalled)
    }
    
    func testViewControllerCallsPresenterOnLikeTap() {
        // given
        let viewController = ImagesListViewController()
        let presenterSpy = ImageListPresenterSpy()
        viewController.configure(presenterSpy)
        
        // when
        viewController.simulateUserDidTapLike(at: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(presenterSpy.buttonLikeIsPushed)
        
    }

    
    
}
