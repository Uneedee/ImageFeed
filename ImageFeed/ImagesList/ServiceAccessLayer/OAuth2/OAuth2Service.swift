import UIKit

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
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
    static let shared = OAuth2Service()
    private init() {}
    
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
    
    func fetchOAuthToken(code: String, completion: @escaping(Result<String, Error>) -> Void ) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            let invalidRequest = NetworkError.invalidRequest
            print("Ошибка. Неверный запрос \(invalidRequest)")
            completion(.failure(invalidRequest))
            return
        }
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    OAuth2TokenStorage.shared.tokenKey = responseBody.accessToken
                    print("Токен успешно получен и сохранен")
                    completion(.success(responseBody.accessToken))}
                catch {
                    completion(.failure(NetworkError.decodingError(error)))
                    let decodingError = NetworkError.decodingError(error)
                    print("Ошибка декодирования: \(decodingError)")
                    }
            case .failure(let error):
                if let networkError = error as? NetworkError {
                    print("Сетевая ошибка: \(networkError)")
                }
                else {
                    print("Неизвестная ошибка: \(error)")
                }
                completion(.failure(error))
                }
            }
        task.resume()
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
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                    print("Ошибка: \(statusCode)")
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                print("Ошибка запроса: \(error)")
                
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                print("Ошибка URLSession")
            }
        })
        
        return task
    }}


