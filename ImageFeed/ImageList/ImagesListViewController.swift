import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
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
        // !Проблема. ЧТобы рассчитать количество строк, нужно чтобы локальный массив был заполнен. А чтобы обновить, нужна разница между старым и новым (т.е. массив должен быть пуст)
        // Где-то тут мы должны получить массив фотографий из listService по ключу из нотификатора и что-то с ним сделать.
    // Надо почитать как извлекать этот массив по ключу и подумать как через него обновлять локальный массив. После этого мы уже спокойно сможем строить таблицу (По-идее)
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
        
        // Тут добавляем нотификацию, которая отслеживает запрос в сеть. (Эта штука нужна только для повторных сетевых запросов) Если он есть, то начинаем подготовку ячеек.
        // Проблема в том что мы должны где-то сразу при входе сделать запрос в сеть, чтобы таблица поняла сколько должно быть строк. Возможно сразу стоит вызвать метод fetchPhotosNextPage.
        // С другой стороны у нас есть метод tableView(_ tableView: UITableView, willDisplay), который уже должен вызывать метод fetchPhotosNextPage. Вопрос в том что вызывается по списку раньше.
        // Если tableView(_ tableView: UITableView, willDisplay), то все ок и вызывать из viewDidLoad() метод fetchPhotosNextPage. не нужно. А если tableView(_ tableView: UITableView, numberOfRowsInSection), то нужно, т.к. он не поймет сколько ячеек создавать.
        // !Сначала вызывается tableView(_:numberOfRowsInSection:) Значит нам сразу нужно как-то наполнить массив photos данными.
        // На момент вызова массив с фото пуст
    }
    
    func updateTableViewAnimated() {
        // Тут проблема. Он добавляет строк столько, сколько есть разницы между локальным массивом и массивом Service. Т.е. они не должны быть равны, чтобы все работало.
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
        // Этап 2 подготовка ячейки
        let photo = photos[indexPath.row]
        let photoUrl = URL(string: photo.thumbImageURL)
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: photoUrl,
            placeholder: UIImage(named: "placeholder")) { _ in
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        
        cell.dateLabel.text = dateFormatter.string(from: currentDate)
        
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
}

extension ImagesListViewController: UITableViewDataSource {
    // Этап 1 - подготовка таблицы (До этого должен быть запрос в сеть)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}





extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Я не уверен что тут правильно выбраны размеры
        let imageSizeWidth = photos[indexPath.row].size.width
        let imageSizeHeight = photos[indexPath.row].size.height
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / imageSizeWidth
        let cellHeight = imageSizeHeight * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    // Этот метод будет запускать сетевой запрос новой партии фотографий при каждом появлении на экране новой ячейки.
    // Но только при условии что количество строк совпадает с количеством фотографий.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
}


