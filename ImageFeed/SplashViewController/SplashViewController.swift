//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 16.12.2025.
//

import UIKit

final class SplashViewController: UIViewController {

    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "splash_screen_logo")
        return iv
    }()

    // MARK: - Lifecycle

    override func loadView() {
        super.loadView()
        view = UIView()
        view.backgroundColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(logoImageView)
        setupConstraints()
        setupDebugClearTokenButtonIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let token = storage.token

        #if DEBUG
        print("[Splash] token read: \(String(describing: token))")
        #endif

        guard let token = token, !token.isEmpty else {
            #if DEBUG
            print("[Splash] no token — presenting Auth")
            #endif
            presentAuthController()
            return
        }

        #if DEBUG
        print("[Splash] token present — validating via fetchProfile")
        #endif

        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success(let profile):
                #if DEBUG
                print("[Splash] fetchProfile success: \(profile.username)")
                #endif
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()

            case .failure(let error):
                #if DEBUG
                print("[Splash] fetchProfile failed: \(error.localizedDescription). Clearing token and presenting Auth.")
                #endif
                self.storage.token = nil
                self.presentAuthController()
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - UI / Navigation

    private func presentAuthController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("AuthViewController storyboard ID not set or wrong type")
            return
        }

        authVC.delegate = self
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true)
    }

    private func switchToTabBarController() {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate,
            let window = sceneDelegate.window
        else {
            assertionFailure("Invalid window configuration")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    // MARK: - Setup

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }

    private func setupDebugClearTokenButtonIfNeeded() {
        #if DEBUG
        let clearButton = UIButton(type: .system)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setTitle("Clear Token (Debug)", for: .normal)
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.addTarget(self, action: #selector(debugClearTokenTapped), for: .touchUpInside)
        view.addSubview(clearButton)

        NSLayoutConstraint.activate([
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clearButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        #endif
    }

    @objc private func debugClearTokenTapped() {
        storage.token = nil
        #if DEBUG
        print("[Splash][DEBUG] Token cleared by user")
        #endif
        presentAuthController()
    }
}

// MARK: - Auth Delegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithToken token: String) {
        #if DEBUG
        print("[Splash] didAuthenticateWithToken: \(token)")
        #endif
        storage.token = token
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
            case .failure:
                self.storage.token = nil
                let alert = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось загрузить профиль", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.presentAuthController()
                })
                self.present(alert, animated: true)
            }
        }
    }
}
