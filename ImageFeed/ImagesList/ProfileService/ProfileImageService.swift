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
        guard let url = URL(string: "https://api.unsplash.com/me/users:\(username)") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
        
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()
        guard let token = OAuth2TokenStorage.shared.tokenKey else {
            print("Ошибка. Токен отсутствует")
            return
        }
        guard let request = makeProfileImageRequest(username: username, token: token) else { return
            completion(.failure(URLError(.badURL)))
        }
        let task = URLSession.shared.data(for: request) { [weak self] result in
            switch result {
            case.success(let data):
                do {
                    let profileImageResult = try JSONDecoder().decode(UserResult.self, from: data)
                    self?.avatarURL = profileImageResult.profileImage.small
                    completion(.success(profileImageResult.profileImage.small))
                }
                catch {
                    completion(.failure(error))
                    print(error)
                }
            case.failure(let error):
                completion(.failure(error))
                
            }
            self?.task = nil
        }
        self.task = task
        task.resume()
    }
}

