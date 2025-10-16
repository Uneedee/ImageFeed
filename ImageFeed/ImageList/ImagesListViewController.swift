import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImageListViewPresenterProtocol? { get set }
    func insertRows(indexPath: [IndexPath])
    func reloadRow(at indexPath: IndexPath)
    func showLikeErrorAlert()
}

final class ImagesListViewController: UIViewController, ImagesListCellDelegate, ImagesListViewControllerProtocol {

    @IBOutlet private var tableView: UITableView!
    var presenter: ImageListViewPresenterProtocol?
    private let currentDate = Date()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if presenter == nil {
            presenter = ImageListViewPresenter()
            presenter?.view = self
            presenter?.configureService(ImagesListService.shared)
        }
        presenter?.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    func configure(_ presenter: ImageListViewPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    func reloadRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func insertRows(indexPath: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPath, with: .automatic)
        } completion: { _ in
        }
    }
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
       guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath)
}
    func simulateUserDidTapLike(at indexPath: IndexPath) {
        presenter?.didTapLike(at: indexPath)
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
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            let imageUrlPath = presenter?.photos[indexPath.row].largeImageURL
            viewController.fullImageUrl = imageUrlPath
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func configCell(for cell: ImagesListCell, photo: Photo) {
        let photoUrl = URL(string: photo.thumbImageURL)
        
        cell.addGradientToImage()
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: photoUrl,
            placeholder: UIImage(named: "placeholder")) { _ in
                cell.removeGradient()
                
            }
        
        if let createdAt = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = ""
        }
        let likeImage = photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        guard let photo = presenter?.photos[indexPath.row] else {
              return cell
          }
        configCell(for: imageListCell, photo: photo)
        imageListCell.delegate = self
        return cell
    }
}





extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let presenter = presenter else { return 0 }
        let imageSizeWidth = presenter.photos[indexPath.row].size.width
        let imageSizeHeight = presenter.photos[indexPath.row].size.height
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / imageSizeWidth
        let cellHeight = imageSizeHeight * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.willDisplayCell(at: indexPath)
    }
}


