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

        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )

        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )

        viewControllers = [imagesListViewController, profileViewController]
    }
}
