import UIKit

    struct Profile{
        let username: String
        let name: String
        let loginName: String
        let bio: String?
    }
    
    struct ProfileResult: Codable {
        let username: String
        let firstname: String
        let lastname: String
        let bio: String?
        
        private enum CodingKeys: String, CodingKey {
            case username
            case firstname = "first_name"
            case lastname = "last_name"
            case bio
        }
    }

final class ProfileService {
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    static let shared = ProfileService()
    private init() {}
    private(set) var profile: Profile?
    
    func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        print("Вызван метод fetchProfile")
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            print("Отсутствует токен в хранилище")
            return
        }
        let task = URLSession.shared.data(for: request) { [weak self] result in
                switch result {
                case .success(let data):
                    do {
                        let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                        let profile = Profile(
                            username: profileResult.username,
                            name: "\(profileResult.firstname) \(profileResult.lastname)",
                            loginName: "@\(profileResult.username)",
                            bio: profileResult.bio)
                        self?.profile = profile
                        completion(.success(profile))
                        print("Декодирование имени прошло успешно")
                    }
                    catch {
                        completion(.failure(error))
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
