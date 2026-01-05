//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 12.11.2025.
//

import UIKit
import Kingfisher

// MARK: - SingleImageViewController

final class SingleImageViewController: UIViewController {

    // URL полноразмерной картинки
    var imageURL: URL?

    private var kfTask: DownloadTask?

    // MARK: - IBOutlets

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!

    @IBAction func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self

        loadImage()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let image = imageView.image {
            rescaleAndCenterImageInScrollView(image: image)
        }
    }

    deinit {
        kfTask?.cancel()
    }

    // MARK: - Private

    private func loadImage() {
        guard let url = imageURL else { return }

        // placeholder можно взять из ассетов, тот же что в ленте
        let placeholder = UIImage(named: "photo_placeholder")

        imageView.kf.indicatorType = .activity

        kfTask = imageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .transition(.fade(0.25)),
                .cacheOriginalImage
            ]
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let value):
                self.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure(let error):
                print("[SingleImageViewController.loadImage]: failure - \(error.localizedDescription)")
                // по желанию можно показать алерт с ошибкой
            }
        }
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale

        view.layoutIfNeeded()

        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size

        guard imageSize.width > 0,
              imageSize.height > 0,
              visibleRectSize.width > 0,
              visibleRectSize.height > 0
        else {
            return
        }

        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))

        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()

        let newContentSize = scrollView.contentSize
        let x = max(0, (newContentSize.width - visibleRectSize.width) / 2)
        let y = max(0, (newContentSize.height - visibleRectSize.height) / 2)
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

