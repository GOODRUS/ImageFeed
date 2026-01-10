//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 05.01.2026.
//

import Foundation

// MARK: - ImagesListService

final class ImagesListService {

    // MARK: - Static

    static let shared = ImagesListService()

    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")

    // MARK: - Public State

    private(set) var photos: [Photo] = []

    // MARK: - Private State

    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let urlSession: URLSession

    // MARK: - Init

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    // MARK: - Public

    func fetchPhotosNextPage() {
        guard task == nil else {
            return
        }

        let nextPage = (lastLoadedPage ?? 0) + 1

        guard let request = makePhotosRequest(page: nextPage) else {
            print("[ImagesListService.fetchPhotosNextPage]: invalidRequest for page \(nextPage)")
            return
        }

        let task = objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            defer { self.task = nil }

            switch result {
            case .success(let photoResults):
                let dateFormatter = ISO8601DateFormatter()
                let newPhotos = photoResults.map { Photo(from: $0, dateFormatter: dateFormatter) }

                photos.append(contentsOf: newPhotos)
                lastLoadedPage = nextPage

                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: ["photos": photos]
                )

            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage]: failure - \(error.localizedDescription)")
            }
        }

        self.task = task
    }

    func changeLike(
        photoId: String,
        isLike: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else {
            print("[ImagesListService.changeLike]: invalidRequest for photoId \(photoId), isLike = \(isLike)")
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                if let index = photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )

                    photos = photos.withReplaced(itemAt: index, newValue: newPhoto)

                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["photos": photos]
                    )
                }

                completion(.success(()))

            case .failure(let error):
                print("[ImagesListService.changeLike]: failure - \(error.localizedDescription) for photoId \(photoId), isLike = \(isLike)")
                completion(.failure(error))
            }
        }

        _ = task
    }

    func reset() {
        task?.cancel()
        task = nil
        lastLoadedPage = nil
        photos = []
    }
}

// MARK: - Private: Requests

private extension ImagesListService {
    func makePhotosRequest(page: Int) -> URLRequest? {
        guard
            let baseURL = Constants.defaultBaseURL,
            var urlComponents = URLComponents(
                url: baseURL.appendingPathComponent("/photos"),
                resolvingAgainstBaseURL: true
            )
        else {
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: "10"),
            URLQueryItem(name: "order_by", value: "latest")
        ]

        guard let url = urlComponents.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard
            let baseURL = Constants.defaultBaseURL,
            let url = URL(string: "/photos/\(photoId)/like", relativeTo: baseURL)
        else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"

        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}

// MARK: - Private: Network helper

private extension ImagesListService {
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
                    print("[ImagesListService.objectTask]: decodingError - \(error.localizedDescription), data: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                print("[ImagesListService.objectTask]: networkError - \(error.localizedDescription) for \(request.url?.absoluteString ?? "")")
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Helpers

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var copy = self
        copy[index] = newValue
        return copy
    }
}
