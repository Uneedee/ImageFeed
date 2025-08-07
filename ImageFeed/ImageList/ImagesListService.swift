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
    
    func makeImageListRequest(page: Int, perPage: Int, token: String) -> URLRequest? {
        

        let baseURL = ImageListUrl.unsplashFetchRequestMakeImageList
        var components = URLComponents(string: "\(baseURL)")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        
        guard let url = components?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchPhotosNextPage(_ completion: @escaping (Result<[Photo], Error>) -> Void)  {
        if task != nil {
            task?.cancel()
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let token = OAuth2TokenStorage.shared.tokenKey else { return }
        guard let request = makeImageListRequest(page: nextPage, perPage: 10, token: token) else { return }
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in switch result {
        case .success(let photoResults):
            guard let self = self else { return }
            for photoResult in photoResults {
                let photo = Photo(id: photoResult.id,
                                  size: CGSize(width: photoResult.width, height: photoResult.height),
                                  createdAt: photoResult.createdAt,
                                  welcomeDescription: photoResult.description,
                                  thumbImageURL: photoResult.imageURL.thumb,
                                  largeImageURL: photoResult.imageURL.full,
                                  isLiked: photoResult.likedByUser)
                photos.append(photo)
            }
            self.lastLoadedPage = nextPage
            NotificationCenter.default.post(
                name: ImagesListService.didChangeNotification,
                object: nil,
                userInfo: ["photos" : photos])
            completion(.success(photos))
        case .failure(let error):
            completion(.failure(error))
            return
        }
        }
        self.task = task
        task.resume()
    }
}

// 1. Нужно получить URLы фотографий, предварительно делая проверку страницы и сохраняя номер последней страницы. Количество фотографий за сессию - 10шт.
// 2. Декодировать ответ и привести его структуре
// 3. Урлы сохранять в массив
