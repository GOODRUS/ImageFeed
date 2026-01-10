//
//  SceneDelegate.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 02.11.2025.
//

import UIKit

// MARK: - SceneDelegate

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties

    var window: UIWindow?

    // MARK: - UIWindowSceneDelegate

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        setupWindow(with: windowScene)
    }
}

// MARK: - Setup

private extension SceneDelegate {
    func setupWindow(with scene: UIWindowScene) {
        let window = UIWindow(windowScene: scene)
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
}
