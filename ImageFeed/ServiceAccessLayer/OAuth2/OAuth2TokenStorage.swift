//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 08.12.2025.
//

import Foundation
import SwiftKeychainWrapper

// MARK: - OAuth2TokenStorage

final class OAuth2TokenStorage {

    // MARK: - Static

    static let shared = OAuth2TokenStorage()

    // MARK: - Init

    private init() { }

    // MARK: - Private

    private let tokenKey = "OAuth2BearerToken"

    // MARK: - Public

    var token: String? {
        get {
            let value = KeychainWrapper.standard.string(forKey: tokenKey)
            #if DEBUG
            print("[OAuth2TokenStorage.get] token = \(String(describing: value))")
            #endif
            return value
        }
        set {
            if let token = newValue {
                let ok = KeychainWrapper.standard.set(token, forKey: tokenKey)
                #if DEBUG
                print("[OAuth2TokenStorage.set] set token = \(token) result = \(ok)")
                #endif
            } else {
                let ok = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                #if DEBUG
                print("[OAuth2TokenStorage.remove] removed token result = \(ok)")
                #endif
            }
        }
    }
}
