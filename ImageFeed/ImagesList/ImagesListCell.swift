//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 04.11.2025.
//

import UIKit
import Kingfisher

// MARK: - ImagesListCell

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var gradientView: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // отменяем загрузку изображения
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        dateLabel.text = nil
        likeButton.setImage(UIImage(named: "like_button_off"), for: .normal)
        likeButton.isEnabled = true
        gradientView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    func setLike(_ isLiked: Bool) {
        let imageName = isLiked ? "like_button_on" : "like_button_off"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
}
