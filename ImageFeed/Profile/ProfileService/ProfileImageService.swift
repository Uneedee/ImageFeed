import UIKit

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
    
    private enum CodingKeys: String, CodingKey {
        case small
        case medium
        case large
        
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    private enum CodingKeys: String,CodingKey {
        case profileImage = "profile_image"
    }
}

final class ProfileImageService {
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    static let shared = ProfileImageService()
    private init() {}
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "\(ProfileImageConstants.unsplashFetchProfileImageURLString)\(username)") else { print("Ошибка в URL получения изображения")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
        
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        print("Вызван метод fetchProfileImageURL")
        task?.cancel()
        guard let token = OAuth2TokenStorage.shared.tokenKey else {
            completion(.failure(NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
            
            print("Ошибка. Токен отсутствует")
            return
        }
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let data):
                guard let self = self else { return }
                self.avatarURL = data.profileImage.large
                completion(.success(data.profileImage.large))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": data.profileImage.large ])
            case .failure(let error):
                completion(.failure(error))
                print(error)
                
            }
        }
        self.task = task
        task.resume()
    }
    
    func clearData() {
        task?.cancel()
        task = nil
        avatarURL = nil
        
    }
    
}




