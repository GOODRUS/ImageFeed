//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 23.11.2025.
//

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithToken token: String)
}

final class AuthViewController: UIViewController {

    weak var delegate: AuthViewControllerDelegate?

    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
    }

    private func showAuthErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    private func showBlockingHUD() {
        UIBlockingProgressHUD.show()
    }

    private func hideBlockingHUD() {
        UIBlockingProgressHUD.dismiss()
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            self.showBlockingHUD()

            self.oauth2Service.fetchOAuthToken(code) { [weak self] result in
                guard let self = self else { return }

                self.hideBlockingHUD()

                switch result {
                case .success(let token):
                    self.dismiss(animated: true) {
                        self.delegate?.authViewController(self, didAuthenticateWithToken: token)
                    }

                case .failure:
                    self.showAuthErrorAlert()
                }
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
