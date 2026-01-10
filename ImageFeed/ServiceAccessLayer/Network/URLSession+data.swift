//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 08.12.2025.
//

import Foundation

// MARK: - NetworkError

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
    case requestAlreadyInProgress
}

// MARK: - URLSession + Data

extension URLSession {

    @discardableResult
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillOnMain: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                print("[URLSession.data]: urlRequestError - \(error.localizedDescription) for \(request.url?.absoluteString ?? "")")
                fulfillOnMain(.failure(NetworkError.urlRequestError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[URLSession.data]: urlSessionError - no HTTPURLResponse for \(request.url?.absoluteString ?? "")")
                fulfillOnMain(.failure(NetworkError.urlSessionError))
                return
            }

            let statusCode = httpResponse.statusCode
            guard (200..<300).contains(statusCode) else {
                print("[URLSession.data]: httpStatusCode - \(statusCode) for \(request.url?.absoluteString ?? "")")
                fulfillOnMain(.failure(NetworkError.httpStatusCode(statusCode)))
                return
            }

            guard let data else {
                print("[URLSession.data]: urlSessionError - nil data for \(request.url?.absoluteString ?? "")")
                fulfillOnMain(.failure(NetworkError.urlSessionError))
                return
            }

            fulfillOnMain(.success(data))
        }

        task.resume()
        return task
    }
}
