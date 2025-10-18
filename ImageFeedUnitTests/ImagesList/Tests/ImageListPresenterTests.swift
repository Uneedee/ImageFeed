import XCTest
@testable import ImageFeed

final class ImageListViewPresenterTests: XCTestCase {
    
    func testViewDidLoad_CallsFetchPhotosNextPage() {
        // given
        let view = ImageListControllerSpy()
        let service = imagesListServiceSpy()
        let sut = ImageListViewPresenter(view: view, imagesListService: service)
        view.presenter = sut
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertFalse(service.photos.isEmpty, "После viewDidLoad должен быть вызван fetchPhotosNextPage()")
    }
    
    func testCalculateInsertedIndexPaths_ReturnsInsertedRows() {
        // given
        let service = imagesListServiceSpy()
        let sut = ImageListViewPresenter(imagesListService: service)
        sut.photos = []

        // when
        service.fetchPhotosNextPage()
        let indexPaths = sut.calculateInsertedIndexPaths()

        // then
        XCTAssertEqual(indexPaths.count, 2, "Должно добавиться 2 новых indexPath")
        XCTAssertEqual(indexPaths.first, IndexPath(row: 0, section: 0))
    }

}
