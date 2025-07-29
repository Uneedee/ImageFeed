import UIKit

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
