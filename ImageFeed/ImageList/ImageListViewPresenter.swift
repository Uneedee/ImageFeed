import UIKit

protocol ImageListViewPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLike(at indexPath: IndexPath)
    var photos: [Photo] { get }
    func willDisplayCell(at indexPath: IndexPath)
    func configureService(_ service: ImagesListServiceProtocol)
}

final class ImageListViewPresenter: ImageListViewPresenterProtocol {
    
    var photos: [Photo] = []
    weak var view: ImagesListViewControllerProtocol?
    private var imageListServiceObserver: NSObjectProtocol?
    var imagesListService: ImagesListServiceProtocol?
    
    init(view: ImagesListViewControllerProtocol? = nil,
         imagesListService: ImagesListServiceProtocol? = nil) {
        self.view = view
        self.imagesListService = imagesListService
    }

    func viewDidLoad() {
        subscribeToImagesListChanges()
        imagesListService?.fetchPhotosNextPage()
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        guard let imagesListService = imagesListService else { return }
        if indexPath.row + 1 == photos.count {
            self.imagesListService?.fetchPhotosNextPage()
        }
    }
    
    func configureService(_ service: ImagesListServiceProtocol) {
        self.imagesListService = service
    }
    
    func subscribeToImagesListChanges() {
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                let indexPath = self.calculateInsertedIndexPaths()
                self.view?.insertRows(indexPath: indexPath)
            }
    }
    
    
    func didTapLike(at indexPath: IndexPath) {
        guard let service = imagesListService else { return }
        let photo = photos[indexPath.row]
         UIBlockingProgressHUD.show()
        service.changeLike(photoId: photo.id) { result in
             switch result {
             case .success:
             
                 self.photos = service.photos
                 self.view?.reloadRow(at: indexPath)
                 UIBlockingProgressHUD.dismiss()
             case .failure:
                 UIBlockingProgressHUD.dismiss()
                 self.view?.showLikeErrorAlert()
             }
             
         }
    }
    
    deinit {
        if let observer = imageListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func calculateInsertedIndexPaths() -> [IndexPath] {
        guard let imagesListService = imagesListService else { return [] }
        let oldPhotosCount = photos.count
        let newPhotosCount = imagesListService.photos.count
        guard oldPhotosCount < newPhotosCount else { return [] }
        photos = imagesListService.photos
        var indexPath: [IndexPath] = []
        for i in oldPhotosCount..<newPhotosCount {
            indexPath.append(IndexPath(row: i, section: 0))
        }
        return indexPath
    }
    
    
}
