//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 08.12.2025.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
    case requestAlreadyInProgress
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

        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                print("[URLSession.data]: urlRequestError - \(error.localizedDescription) for \(request.url?.absoluteString ?? "")")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[URLSession.data]: urlSessionError - no HTTPURLResponse for \(request.url?.absoluteString ?? "")")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                return
            }

            let statusCode = httpResponse.statusCode
            guard 200 ..< 300 ~= statusCode else {
                print("[URLSession.data]: httpStatusCode - \(statusCode) for \(request.url?.absoluteString ?? "")")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                return
            }

            if let data = data {
                fulfillCompletionOnTheMainThread(.success(data))
            } else {
                print("[URLSession.data]: urlSessionError - nil data for \(request.url?.absoluteString ?? "")")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        }

        task.resume()
        return task
    }
}
