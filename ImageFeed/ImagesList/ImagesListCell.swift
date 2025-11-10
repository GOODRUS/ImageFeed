//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 04.11.2025.
//

import UIKit

// MARK: - ImagesListCell

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
}
