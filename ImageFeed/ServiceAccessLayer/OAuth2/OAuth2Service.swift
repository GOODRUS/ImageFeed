//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 07.12.2025.
//

import Foundation

// MARK: - OAuth2Service

final class OAuth2Service {

    // MARK: - Static

    static let shared = OAuth2Service()

    // MARK: - Dependencies

    private let dataStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared

    // MARK: - Public State

    private(set) var authToken: String? {
        get { dataStorage.token }
        set { dataStorage.token = newValue }
    }

    // MARK: - Race protection

    private var currentTask: URLSessionTask?
    private var currentCode: String?

    // MARK: - Init

    private init() { }

    // MARK: - Public

    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        if let task = currentTask {
            if currentCode == code {
                let error = NetworkError.requestAlreadyInProgress
                print("[OAuth2Service.fetchOAuthToken]: requestAlreadyInProgress for code \(code)")
                completion(.failure(error))
                return
            } else {
                task.cancel()
                currentTask = nil
                currentCode = nil
            }
        }

        guard let request = makeOAuthTokenRequest(code: code) else {
            let error = NetworkError.invalidRequest
            print("[OAuth2Service.fetchOAuthToken]: invalidRequest for code \(code)")
            completion(.failure(error))
            return
        }

        currentCode = code

        let task = objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }

            currentTask = nil
            currentCode = nil

            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))

            case .failure(let error):
                print("[OAuth2Service.fetchOAuthToken]: failure - \(error.localizedDescription) for code \(code)")
                completion(.failure(error))
            }
        }

        currentTask = task
    }
}

// MARK: - Private: Requests

private extension OAuth2Service {
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let params: [String: String] = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]

        let bodyString = params
            .map { key, value in
                let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
                return "\(escapedKey)=\(escapedValue)"
            }
            .joined(separator: "&")

        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded;charset=utf-8", forHTTPHeaderField: "Content-Type")

        return request
    }
}

// MARK: - Private: Models

private extension OAuth2Service {
    struct OAuthTokenResponseBody: Codable {
        let accessToken: String

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
}

// MARK: - Private: Network helper

private extension OAuth2Service {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()

        return urlSession.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("[OAuth2Service.objectTask]: Decoding error: \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                print("[OAuth2Service.objectTask]: failure - \(error.localizedDescription) for \(request.url?.absoluteString ?? "")")
                completion(.failure(error))
            }
        }
    }
}
