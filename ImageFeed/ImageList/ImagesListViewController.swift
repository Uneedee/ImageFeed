import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListCellDelegate {
    

    
    
    @IBOutlet private var tableView: UITableView!
    
    let imagesListService = ImagesListService()
    
    private var imageListServiceObserver: NSObjectProtocol?

    
    private let currentDate = Date()
    
    var photos: [Photo] = []
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                        self.updateTableViewAnimated()
                    print("photos count \(self.photos.count)")
                
            }
        imagesListService.fetchPhotosNextPage()
    }
    
    func updateTableViewAnimated() {
        // Тут мы добавили проверку массива фотографий на разницу и присвоили локальному массиву массив из сервиса.
        let oldPhotosCount = photos.count
        let newPhotosCount = imagesListService.photos.count
        print("Количество строк локального массива \(oldPhotosCount)")
        print("Количество строк нового сервис массива \(newPhotosCount)")
        
        guard oldPhotosCount != newPhotosCount else {
            return
        }
        photos = imagesListService.photos
        var indexPath: [IndexPath] = []
        for i in oldPhotosCount..<newPhotosCount {
            indexPath.append(IndexPath(row: i, section: 0))
        }
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPath, with: .automatic)
        } completion: { _ in }
        
    }
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
       guard let indexPath = tableView.indexPath(for: cell) else { return }
       let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id) { result in
            switch result {
            case .success:
            
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showLikeErrorAlert()
            }
            
        }
        

    }
    
    func showLikeErrorAlert() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так(" ,
            message: "Не удалось поставить лайк",
            preferredStyle: .alert)
        
        let alertAction = UIAlertAction(
            title: "OK",
            style: .default)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == showSingleImageSegueIdentifier {
//            guard
//                let viewController = segue.destination as? SingleImageViewController,
//                let indexPath = sender as? IndexPath
//            else {
//                assertionFailure("Invalid segue destination")
//                return
//            }
//            
//            let image = UIImage(named: photosName[indexPath.row])
//            viewController.image = image
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let photoUrl = URL(string: photo.thumbImageURL)
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: photoUrl,
            placeholder: UIImage(named: "placeholder")) { _ in
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        // Из-за этой штуки при листании вверх пропадают фотографии
        
        cell.dateLabel.text = dateFormatter.string(from: currentDate)
        
//        let isLiked = indexPath.row % 2 == 0
        let likeImage = photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self

        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}





extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageSizeWidth = photos[indexPath.row].size.width
        let imageSizeHeight = photos[indexPath.row].size.height
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / imageSizeWidth
        let cellHeight = imageSizeHeight * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
}


