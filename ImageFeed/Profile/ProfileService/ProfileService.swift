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
        guard let url = URL(string: ProfileConstants.unsplashFetchProfileURLString) else {
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
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result:Result<ProfileResult, Error>) in
            switch result {
            case .success(let data):
                let profile = Profile(username: data.username,
                                      name: "\(data.firstname) \(data.lastname)",
                                      loginName: "@\(data.username)",
                                      bio: data.bio)
                self?.profile = profile
                completion(.success(profile))
                print("Экземпляр профиля создан успешно")
            case .failure(let error):
                completion(.failure(error))
                print("Ошибка создания экземпляра профиля")
            }
            self?.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func clearData() {
        task?.cancel()
        task = nil
        profile = nil
        
    }
}
