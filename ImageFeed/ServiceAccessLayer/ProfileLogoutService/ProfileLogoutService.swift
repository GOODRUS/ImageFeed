//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 05.01.2026.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()

    private init() { }

    func logout() {
        // 1. Удаляем токен
        OAuth2TokenStorage.shared.token = nil

        // 2. Сбрасываем данные профиля
        ProfileService.shared.reset()

        // 3. Сбрасываем аватарку
        ProfileImageService.shared.reset()

        // 4. Сбрасываем список фотографий (и состояние пагинации)
        ImagesListService.shared.reset()

        // 5. Чистим cookies / local storage WebView
        cleanCookies()
    }

    // MARK: - Private

    private func cleanCookies() {
        // Очищаем все куки из общего хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        // Очищаем данные WebKit (local storage, cache и т.п.)
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
