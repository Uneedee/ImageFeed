import UIKit


struct PhotoIsLiked: Codable {
    let photo: PhotoLike
    
    private enum CodingKeys: String, CodingKey {
        case photo = "photo"
    }
    
}

struct PhotoLike: Codable {
    let id: String
    let likedByUser: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case likedByUser = "liked_by_user"
    }
}

struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String
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
    var isLiked: Bool
}

final class ImagesListService {
    private(set) var photos: [Photo] = []
    private var task: URLSessionTask?
    static let shared = ImagesListService()

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
    
    func fetchPhotosNextPage() {
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
                                  createdAt: parseDate(from: photoResult.createdAt),
                                  welcomeDescription: photoResult.description,
                                  thumbImageURL: photoResult.imageURL.thumb,
                                  largeImageURL: photoResult.imageURL.full,
                                  isLiked: photoResult.likedByUser)
                self.photos.append(photo)
                
            }
            self.lastLoadedPage = nextPage
            NotificationCenter.default.post(
                name: ImagesListService.didChangeNotification,
                object: nil,
                userInfo: ["photos" : photos])
        case .failure:
            return
        }
        }
        self.task = task
        task.resume()
    }
    
    private func parseDate(from dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
    
    func changeLike(photoId: String, _ completion: @escaping (Result<Void, Error>) -> Void)  {
        
        var request: URLRequest?
        
        if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
            let photo = self.photos[index]
            if photo.isLiked == true { request = makePhotosDislikeRequest(id: photoId) } else { request = makePhotosLikeRequest(id: photoId)}
        }
        
        guard let makeRequest = request else { return }
        
        let task = URLSession.shared.objectTask(for: makeRequest) { [weak self] (result: Result<PhotoIsLiked, Error>) in switch result {
        case .success:
            guard let self = self else { return }
            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                let photo = self.photos[index]
                let newPhoto = Photo(
                    id: photo.id,
                    size: photo.size,
                    createdAt: photo.createdAt,
                    welcomeDescription: photo.welcomeDescription,
                    thumbImageURL: photo.thumbImageURL,
                    largeImageURL: photo.largeImageURL,
                    isLiked: !photo.isLiked
                )
                self.photos[index] = newPhoto
            }
            completion(.success(()))

        case .failure(let error):
            completion(.failure(error))
        }
        }
        task.resume()
        
    }
    
    func makePhotosLikeRequest(id: String) -> URLRequest? {
        
        let baseUrl = ImageListUrl.unsplashFetchRequestMakeImageList
        
        guard let url = URL(string: "\(baseUrl)/\(id)/like") else { return nil }
        guard let token = OAuth2TokenStorage.shared.tokenKey else { print("Токен отсутствует")
            return nil }
                
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
        
    }
    
    
    func makePhotosDislikeRequest(id: String) -> URLRequest? {
        
        //Всегда ли нужно добавлять хеддер при запросах?
        
        let baseUrl = ImageListUrl.unsplashFetchRequestMakeImageList
        
        guard let url = URL(string: "\(baseUrl)/\(id)/like") else { return nil }
        guard let token = OAuth2TokenStorage.shared.tokenKey else { print("Токен отсутствует")
            return nil }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
        
    }
    
    
    
}
