//
//  ImagesListModels.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 05.01.2026.
//

import UIKit

// MARK: - Domain model (для UI)

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

// MARK: - Network models (DTO)

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let altDescription: String?
    let likedByUser: Bool
    let urls: UrlsResult

    private enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case description
        case altDescription = "alt_description"
        case likedByUser = "liked_by_user"
        case urls
    }
}

struct UrlsResult: Decodable {
    let thumb: String
    let full: String
    // при необходимости можно добавить small/regular:
    // let small: String
    // let regular: String
}

// MARK: - Mapping PhotoResult -> Photo

extension Photo {
    init(from result: PhotoResult, dateFormatter: ISO8601DateFormatter = ISO8601DateFormatter()) {
        let size = CGSize(width: CGFloat(result.width), height: CGFloat(result.height))

        let createdAtDate: Date?
        if let createdAtString = result.createdAt {
            createdAtDate = dateFormatter.date(from: createdAtString)
        } else {
            createdAtDate = nil
        }

        let description = result.description ?? result.altDescription

        self.init(
            id: result.id,
            size: size,
            createdAt: createdAtDate,
            welcomeDescription: description,
            thumbImageURL: result.urls.thumb,
            largeImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
    }
}
