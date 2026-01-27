//
//  ProfileViewProtocol.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 25.01.2026.
//

import Foundation

// MARK: - ProfileViewProtocol

protocol ProfileViewProtocol: AnyObject {
    func updateProfileDetails(name: String, loginName: String, bio: String?)
    func updateAvatar(with url: URL?)
    func showLogoutAlert()
    func switchToSplashScreen()
}
