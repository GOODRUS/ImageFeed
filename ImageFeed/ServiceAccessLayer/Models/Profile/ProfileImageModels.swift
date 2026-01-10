//
//  ProfileImageModels.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 04.01.2026.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage

    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }

    struct ProfileImage: Codable {
        let small: String
    }
}
