//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 25.01.2026.
//

import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {

    // MARK: - Dependencies

    private weak var view: ImagesListViewProtocol?
    private let imagesListService: ImagesListService

    // MARK: - State

    private var photos: [Photo] = []
    private var serviceObserver: NSObjectProtocol?

    // MARK: - Init

    init(
        view: ImagesListViewProtocol,
        imagesListService: ImagesListService = .shared
    ) {
        self.view = view
        self.imagesListService = imagesListService
        setupObserver()
    }

    deinit {
        if let observer = serviceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - ImagesListPresenterProtocol

    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage()
    }

    func numberOfRows() -> Int {
        photos.count
    }

    func photo(at index: Int) -> Photo {
        photos[index]
    }

    func willDisplayCell(at index: Int) {
        let photosCount = photos.count
        if index + 1 == photosCount {
            imagesListService.fetchPhotosNextPage()
        }
    }

    func didTapLike(
        at index: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let photo = photos[index]
        let newIsLike = !photo.isLiked

        imagesListService.changeLike(photoId: photo.id, isLike: newIsLike) { [weak self] result in guard self != nil else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }

            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Observer

private extension ImagesListPresenter {
    func setupObserver() {
        serviceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }

            let oldCount = self.photos.count
            self.photos = self.imagesListService.photos
            let newCount = self.photos.count

            self.view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }
}
