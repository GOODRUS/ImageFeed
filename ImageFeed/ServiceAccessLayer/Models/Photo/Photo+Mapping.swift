//
//  Photo+Mapping.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 10.01.2026.
//

import UIKit

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
