import UIKit

final class OAuth2Service {
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    static let shared = OAuth2Service()
    private init() {}
    
    func fetchOAuthToken(code: String, completion: @escaping(Result<String, Error>) -> Void ) {
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        guard
            let request = makeOAuthTokenRequest(code: code)
        else {
            let invalidRequest = AuthServiceError.invalidRequest
            print("Ошибка. Неверный запрос \(invalidRequest)")
            completion(.failure(invalidRequest))
            return
        }
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                
                switch result {
                case .success(let data):
                    let authToken = data.accessToken
                    OAuth2TokenStorage.shared.tokenKey = authToken
                    print("Token saved successfully")
                    completion(.success(authToken))
                    
                    self.task = nil
                    self.lastCode = nil
                    
                case .failure(let error):
                    
                    completion(.failure(error))
                    
                    self.task = nil
                    self.lastCode = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
}


private func makeOAuthTokenRequest(code: String) -> URLRequest? {
    guard var urlComponents = URLComponents(string: AuthConstants.authForFetchTokenURLString) else {
        print("Ошибка в URL Components")
        return nil
    }
    urlComponents.queryItems = [
        URLQueryItem(name: "client_id", value: Constants.accessKey),
        URLQueryItem(name: "client_secret", value: Constants.secretKey),
        URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
        URLQueryItem(name: "code", value: code),
        URLQueryItem(name: "grant_type", value: "authorization_code")
    ]
    
    guard let authTokenUrl = urlComponents.url else {
        print("Ошибка в создании URL с queryItems")
        return nil
    }
    var request = URLRequest(url: authTokenUrl)
    request.httpMethod = "POST"
    return request
}



