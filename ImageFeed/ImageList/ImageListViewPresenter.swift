import UIKit

protocol ImageListViewPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLike(at indexPath: IndexPath)
    var photos: [Photo] { get }
    func willDisplayCell(at indexPath: IndexPath)
}

final class ImageListViewPresenter: ImageListViewPresenterProtocol {
    func didTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
         UIBlockingProgressHUD.show()
         imagesListService.changeLike(photoId: photo.id) { result in
             switch result {
             case .success:
             
                 self.photos = self.imagesListService.photos
                 self.view?.reloadRow(at: indexPath)
                 UIBlockingProgressHUD.dismiss()
             case .failure:
                 UIBlockingProgressHUD.dismiss()
                 self.view?.showLikeErrorAlert()
             }
             
         }
    }
    

    var photos: [Photo] = []
    weak var view: ImagesListViewControllerProtocol?
    private var imageListServiceObserver: NSObjectProtocol?
    let imagesListService = ImagesListService()

    func viewDidLoad() {
        subscribeToImagesListChanges()
        imagesListService.fetchPhotosNextPage()
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    
    func subscribeToImagesListChanges() {
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                var indexPath = self.calculateInsertedIndexPaths()
                self.view?.insertRows(indexPath: indexPath)
            }
    }
    
    deinit {
        if let observer = imageListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func calculateInsertedIndexPaths() -> [IndexPath] {
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
