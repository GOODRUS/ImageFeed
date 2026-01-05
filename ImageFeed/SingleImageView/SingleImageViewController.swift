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

        scrollView.delegate = self

        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0

        imageView.contentMode = .scaleAspectFit

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
            }
        }
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()

        let scrollViewSize = scrollView.bounds.size
        let imageSize = image.size

        guard imageSize.width > 0,
              imageSize.height > 0,
              scrollViewSize.width > 0,
              scrollViewSize.height > 0
        else {
            return
        }

        let hScale = scrollViewSize.width / imageSize.width
        let vScale = scrollViewSize.height / imageSize.height
        let fittingScale = min(hScale, vScale)

        let minScale = fittingScale
        let maxScale = max(fittingScale * 4.0, 4.0)

        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = maxScale

        scrollView.setZoomScale(minScale, animated: false)

        centerImage()
    }

    private func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize

        let horizontalInset = max(0, (scrollViewSize.width - contentSize.width) / 2)
        let verticalInset = max(0, (scrollViewSize.height - contentSize.height) / 2)

        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
