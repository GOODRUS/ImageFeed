//
//  Profile+Mapping.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 10.01.2026.
//

import Foundation

extension Profile {
    init(from result: ProfileResult) {
        let fullName: String
        if let last = result.lastName, !last.isEmpty {
            fullName = "\(result.firstName) \(last)"
        } else {
            fullName = result.firstName
        }

        self.init(
            username: result.username,
            name: fullName,
            loginName: "@\(result.username)",
            bio: result.bio
        )
    }
}
