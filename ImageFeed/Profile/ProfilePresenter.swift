//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 25.01.2026.
//

import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - Dependencies
    
    private weak var view: ProfileViewProtocol?
    private let profileService: ProfileService
    private let profileImageService: ProfileImageService
    private let logoutService: ProfileLogoutService
    
    // MARK: - State
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Init
    
    init(
        view: ProfileViewProtocol,
        profileService: ProfileService = .shared,
        profileImageService: ProfileImageService = .shared,
        logoutService: ProfileLogoutService = .shared
    ) {
        self.view = view
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
        
        setupObservers()
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - ProfilePresenterProtocol
    
    func viewDidLoad() {
        if let profile = profileService.profile {
            view?.updateProfileDetails(
                name: profile.name,
                loginName: profile.loginName,
                bio: profile.bio
            )
        }
        
        if let avatarString = profileImageService.avatarURL,
           let url = URL(string: avatarString) {
            view?.updateAvatar(with: url)
        }
    }
    
    func didTapLogout() {
        // Просим view показать алерт подтверждения
        view?.showLogoutAlert()
    }
    
    func didConfirmLogout() {
        performLogout()
    }
}

// MARK: - Observers

private extension ProfilePresenter {
    func setupObservers() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard
                let self,
                let userInfo = notification.userInfo,
                let urlString = userInfo["url"] as? String,
                let url = URL(string: urlString)
            else {
                return
            }
            
            self.view?.updateAvatar(with: url)
        }
    }
    
    func performLogout() {
        logoutService.logout()
        view?.switchToSplashScreen()
    }
}
