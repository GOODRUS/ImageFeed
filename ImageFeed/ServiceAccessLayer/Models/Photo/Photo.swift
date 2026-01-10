//
//  Photo.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 10.01.2026.
//

import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
