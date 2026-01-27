//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 21.01.2026.
//
import Foundation

// MARK: - AuthConfiguration

struct AuthConfiguration {
    let authURLString: String
    let accessKey: String
    let redirectURI: String
    let accessScope: String

    static var standard: AuthConfiguration {
        AuthConfiguration(
            authURLString: "https://unsplash.com/oauth/authorize",
            accessKey: Constants.accessKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope
        )
    }
}
