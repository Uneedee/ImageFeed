import UIKit

struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: Date?
    let description: String?
    let imageURL: UrlsResult
    let likedByUser: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case description
        case imageURL = "urls"
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    
    
    private enum CodingKeys: String, CodingKey {
        case raw
        case full
        case regular
        case small
        case thumb
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

final class ImagesListService {
    private(set) var photos: [Photo] = []
    private var task: URLSessionTask?
    
    private var lastLoadedPage: Int?
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func makeImageListRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "\(ImageListUrl.unsplashFetchRequestMakeImageList)") else {
            print("Ошибка URL при получении фотографий")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchPhotosNextPage(_ completion: @escaping (Result<String, Error>) -> Void)  {
        task?.cancel()
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let token = OAuth2TokenStorage.shared.tokenKey else { return }
        guard let request = makeImageListRequest(token: token) else { return }
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<PhotoResult, Error>) in switch result {
        case .success(let data):
            guard let self = self else { return }
            let photo = Photo(id: data.id,
                              size: CGSize(width: data.width, height: data.height),
                              createdAt: data.createdAt,
                              welcomeDescription: data.description,
                              thumbImageURL: data.imageURL.thumb,
                              largeImageURL: data.imageURL.full,
                              isLiked: data.likedByUser)
            NotificationCenter.default.post(
                name: ImagesListService.didChangeNotification,
                object: nil,
                userInfo: ["photo" : photo])
        case .failure(let error):
            completion(.failure(error))
        }
        }
        self.task = task
        task.resume()
    }
}

// 1. Нужно получить URLы фотографий, предварительно делая проверку страницы и сохраняя номер последней страницы. Количество фотографий за сессию - 10шт.
// 2. Декодировать ответ и привести его структуре
// 3. Урлы сохранять в массив
