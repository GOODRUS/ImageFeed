//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 05.01.2026.
//

import Foundation
import WebKit

// MARK: - ProfileLogoutService

final class ProfileLogoutService {

    // MARK: - Static

    static let shared = ProfileLogoutService()

    // MARK: - Init

    private init() { }

    // MARK: - Public

    func logout() {
        OAuth2TokenStorage.shared.token = nil
        ProfileService.shared.reset()
        ProfileImageService.shared.reset()
        ImagesListService.shared.reset()
        cleanCookies()
    }
}

// MARK: - Private

private extension ProfileLogoutService {
    func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes,
                    for: [record],
                    completionHandler: {}
                )
            }
        }
    }
}
