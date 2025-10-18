@testable import ImageFeed
import UIKit

final class ImageListPresenterSpy: ImageListViewPresenterProtocol {
    
    func configureService(_ service: any ImageFeed.ImagesListServiceProtocol) {
//        imagesListService = service
    }
    
    var view: (any ImageFeed.ImagesListViewControllerProtocol)?
    var viewDidLoadIsCalled = false
    var buttonLikeIsPushed = false
    var willDisplayCellCalled = false
    var photos: [ImageFeed.Photo] = []
    
    func viewDidLoad() {
        viewDidLoadIsCalled = true
        
    }
    
    func didTapLike(at indexPath: IndexPath) {
        buttonLikeIsPushed = true
    }

    
    func willDisplayCell(at indexPath: IndexPath) {
        willDisplayCellCalled = true
    }
    
    
}
