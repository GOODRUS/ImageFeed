//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 07.12.2025.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private var task: URLSessionTask?
    private let tokenStorage = OAuth2TokenStorage()

    private init() { }

    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        task?.cancel()

        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Ошибка: некорректный запрос (invalidRequest)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    self.tokenStorage.token = response.accessToken
                    completion(.success(response.accessToken))
                } catch {
                    print("Ошибка декодирования токена: \(error)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                switch error {
                case NetworkError.httpStatusCode(let code):
                    print("Ошибка сервиса Unsplash: HTTP статус-код \(code)")
                case NetworkError.urlRequestError(let err):
                    print("Сетевая ошибка: \(err.localizedDescription)")
                default:
                    print("Другая ошибка: \(error)")
                }
                completion(.failure(error))
            }
        }
        task?.resume()
    }
}
