//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 27.12.2025.
//

import UIKit

// MARK: - TabBarController

final class TabBarController: UITabBarController {

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViewControllers()
    }
}

// MARK: - Setup

private extension TabBarController {
    func setupViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        // Лента
        guard let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController else {
            assertionFailure("ImagesListViewController not found in storyboard")
            return
        }
        let imagesListPresenter = ImagesListPresenter(view: imagesListViewController)
        imagesListViewController.configure(imagesListPresenter)

        // Профиль
        let profileViewController = ProfileViewController()
        let profileTabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        profileTabBarItem.accessibilityIdentifier = "Profile"
        profileViewController.tabBarItem = profileTabBarItem

        let profilePresenter = ProfilePresenter(
            view: profileViewController
        )
        profileViewController.configure(profilePresenter)

        viewControllers = [imagesListViewController, profileViewController]
    }
}
