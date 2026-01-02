//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 23.12.2025.
//

import Foundation

// MARK: - Models

struct UserResult: Codable {
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }

    struct ProfileImage: Codable {
        let small: String
    }
}

// MARK: - ProfileImageService

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    private(set) var avatarURL: String?

    private let urlSession = URLSession.shared
    private var task: URLSessionTask?

    private init() {}

    // MARK: - Networking

    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        task?.cancel()

        guard let request = makeProfileImageRequest(username: username) else {
            let error = URLError(.badURL)
            print("[ProfileImageService.fetchProfileImageURL]: invalidRequest for username \(username)")
            completion(.failure(error))
            return
        }

        let task = objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            defer { self.task = nil }

            switch result {
            case .success(let userResult):
                let profileImageURL = userResult.profileImage.small
                self.avatarURL = profileImageURL
                completion(.success(profileImageURL))

                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageURL]
                )

            case .failure(let error):
                print("[ProfileImageService.fetchProfileImageURL]: failure - \(error.localizedDescription) for username \(username)")
                completion(.failure(error))
            }
        }

        self.task = task
    }

    // MARK: - Private

    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard
            let baseURL = Constants.defaultBaseURL,
            let url = URL(string: "/users/\(username)", relativeTo: baseURL)
        else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
}

// MARK: - Network helper

private extension ProfileImageService {
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
                    print("[ProfileImageService.objectTask]: decodingError - \(error.localizedDescription), data: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                print("[ProfileImageService.objectTask]: networkError - \(error.localizedDescription) for \(request.url?.absoluteString ?? "")")
                completion(.failure(error))
            }
        }
    }
}
