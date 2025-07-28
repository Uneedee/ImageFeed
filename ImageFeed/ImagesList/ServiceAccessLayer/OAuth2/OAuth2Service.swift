import UIKit

enum AuthServiceError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(DecodingError)
}

struct OAuthTokenResponseBody: Decodable {
    
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}

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
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
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
    

//    }

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let task = data(for: request) { (result: Result<Data, Error>) in
                switch result {
                case .success(let data):
                    do {
                        let decodedObject = try decoder.decode(T.self, from: data)
                        print("Decoding success")
                        completion(.success(decodedObject))
                    } catch {
                        if let decodingError = error as? DecodingError {
                            let authError = AuthServiceError.decodingError(decodingError)
                            print("Ошибка декодирования: \(authError), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                        } else {
                            print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                        }
                        completion(.failure(error))
                        
                    } 
                case .failure(let error):
                    print("Ошибка запроса: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            
        }
        return task
    }
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(AuthServiceError.httpStatusCode(statusCode)))
                    print("Ошибка: \(statusCode)")
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(AuthServiceError.urlRequestError(error)))
                print("Ошибка запроса: \(error)")
                
            } else {
                fulfillCompletionOnTheMainThread(.failure(AuthServiceError.urlSessionError))
                print("Ошибка URLSession")
            }
        })
        
        return task
    }}


