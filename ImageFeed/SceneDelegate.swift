//
//  SceneDelegate.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 02.11.2025.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        setupWindow(with: windowScene)
    }
}

// MARK: - Private

private extension SceneDelegate {
    func setupWindow(with scene: UIWindowScene) {
        let window = UIWindow(windowScene: scene)
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
}
