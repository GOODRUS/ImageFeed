//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 16.12.2025.
//

import UIKit

// MARK: - SplashViewController

final class SplashViewController: UIViewController {

    // MARK: - Dependencies

    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared

    // MARK: - UI

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "splash_screen_logo")
        return iv
    }()

    // MARK: - Lifecycle

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDebugClearTokenButtonIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthentication()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

// MARK: - Setup

private extension SplashViewController {
    func setupUI() {
        view.addSubview(logoImageView)
        setupConstraints()
    }

    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }

    func setupDebugClearTokenButtonIfNeeded() {
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
}

// MARK: - Auth Flow

private extension SplashViewController {
    func checkAuthentication() {
        let token = storage.token

        #if DEBUG
        let hasToken = (token?.isEmpty == false)
        print("[Splash] token present: \(hasToken)")
        #endif

        guard let token = token, !token.isEmpty else {
            #if DEBUG
            print("[Splash] no token — presenting Auth")
            #endif
            presentAuthControllerIfNeeded()
            return
        }

        fetchProfile(with: token)
    }

    func fetchProfile(with token: String) {
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
                self.handleProfileFetchError(error)
            }
        }
    }

    func handleProfileFetchError(_ error: Error) {
        if case NetworkError.urlRequestError(let urlError) = error,
           (urlError as NSError).code == NSURLErrorCancelled {
            #if DEBUG
            print("[Splash] fetchProfile cancelled - ignoring")
            #endif
            return
        }

        if case NetworkError.httpStatusCode(let status) = error, status == 401 {
            #if DEBUG
            print("[Splash] fetchProfile unauthorized (401) - clearing token and presenting Auth")
            #endif
            storage.token = nil
            presentAuthControllerIfNeeded()
            return
        }

        #if DEBUG
        print("[Splash] fetchProfile non-auth error: \(error.localizedDescription)")
        #endif
    }
}

// MARK: - Navigation

private extension SplashViewController {
    func presentAuthControllerIfNeeded() {
        if presentedViewController is AuthViewController { return }

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard
            let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
        else {
            assertionFailure("AuthViewController storyboard ID not set or wrong type")
            return
        }

        authVC.delegate = self
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true)
    }

    func switchToTabBarController() {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else {
            assertionFailure("Invalid window configuration")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController
        else {
            assertionFailure("TabBarViewController storyboard ID not set or wrong type")
            return
        }

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

// MARK: - Actions

private extension SplashViewController {
    @objc func debugClearTokenTapped() {
        storage.token = nil
        #if DEBUG
        print("[Splash][DEBUG] Token cleared by user")
        #endif
        presentAuthControllerIfNeeded()
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithToken token: String) {
        #if DEBUG
        print("[Splash] didAuthenticateWithToken: token received")
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

            case .failure(let error):
                self.handleProfileFetchAfterAuthError(error)
            }
        }
    }

    private func handleProfileFetchAfterAuthError(_ error: Error) {
        if case NetworkError.urlRequestError(let urlError) = error,
           (urlError as NSError).code == NSURLErrorCancelled {
            #if DEBUG
            print("[Splash] fetchProfile cancelled after auth - ignoring")
            #endif
            return
        }

        if case NetworkError.httpStatusCode(let status) = error, status == 401 {
            storage.token = nil
            presentAuthControllerIfNeeded()
            return
        }

        let alert = UIAlertController(
            title: NSLocalizedString("error_title", comment: "Generic error title"),
            message: NSLocalizedString("profile_load_failed_message", comment: "Profile load failed"),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("ok_button", comment: "OK"),
                style: .default
            ) { _ in
                self.presentAuthControllerIfNeeded()
            }
        )
        present(alert, animated: true)
    }
}
