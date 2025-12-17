//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 08.12.2025.
//

import Foundation

final class OAuth2TokenStorage {
    private let tokenKey = "OAuth2BearerToken"

    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
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
