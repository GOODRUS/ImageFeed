//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 08.12.2025.
//

import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()

    private init() {}

    private let tokenKey = "OAuth2BearerToken"

    var token: String? {
        get {
            let value = UserDefaults.standard.string(forKey: tokenKey)
            return value
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: tokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
