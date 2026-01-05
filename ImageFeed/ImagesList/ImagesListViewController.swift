//
//  ViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 02.11.2025.
//

import UIKit
import Kingfisher

// MARK: - ImagesListViewController

final class ImagesListViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!

    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    private let imagesListService = ImagesListService.shared

    // Локальный массив фотографий для таблицы
    private var photos: [Photo] = []

    // Observer для нотификаций сервиса
    private var imagesListServiceObserver: NSObjectProtocol?

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1) // #1A1B22
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        // подписка на обновления из ImagesListService
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }

        // загрузка первой страницы
        imagesListService.fetchPhotosNextPage()
    }

    deinit {
        if let observer = imagesListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let photo = photos[indexPath.row]
            if let url = URL(string: photo.largeImageURL) {
                viewController.imageURL = url
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - Private Methods

private extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]

        cell.gradientView.backgroundColor = UIColor.clear

        // Placeholder из ассетов (выгруженный из Figma)
        let placeholderImage = UIImage(named: "photo_placeholder")

        // Включаем индикатор активности
        cell.cellImage.kf.indicatorType = .activity

        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: placeholderImage,
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        } else {
            // если url невалиден — ставим заглушку
            cell.cellImage.image = placeholderImage
        }

        if let createdAt = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = ""
        }

        cell.setLike(photo.isLiked)

        cell.likeButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.likeButton.addTarget(self, action: #selector(didTapLikeButton(_:)), for: .touchUpInside)
        cell.likeButton.tag = indexPath.row
    }

    @objc func didTapLikeButton(_ sender: UIButton) {
        let index = sender.tag
        let photo = photos[index]
        let newIsLike = !photo.isLiked

        imagesListService.changeLike(photoId: photo.id, isLike: newIsLike) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                // состояние photos обновится в сервисе и придёт нотификация,
                // updateTableViewAnimated() перерисует таблицу
                break
            case .failure(let error):
                print("[ImagesListViewController.didTapLikeButton]: like failed - \(error.localizedDescription)")
            }
        }
    }

    func updateTableViewAnimated() {
        let newPhotos = imagesListService.photos

        let oldCount = photos.count
        let newCount = newPhotos.count

        photos = newPhotos

        guard newCount > oldCount else {
            tableView.reloadData()
            return
        }

        let indexPaths = (oldCount..<newCount).map { row in
            IndexPath(row: row, section: 0)
        }

        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath)

        return imageListCell
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageSize = photo.size

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = imageSize.width
        guard imageWidth > 0, imageViewWidth > 0 else {
            return 0
        }

        let scale = imageViewWidth / imageWidth
        let cellHeight = imageSize.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        let photosCount = photos.count

        if indexPath.row + 1 == photosCount {
            imagesListService.fetchPhotosNextPage()
        }
    }
}
     
                                        
