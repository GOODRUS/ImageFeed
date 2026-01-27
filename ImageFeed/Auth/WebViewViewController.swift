//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 24.11.2025.
//

import UIKit
import WebKit

// MARK: - WebViewViewControllerDelegate

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

// MARK: - WebViewViewController

final class WebViewViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!

    // MARK: - Dependencies

    weak var delegate: WebViewViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?

    // MARK: - State

    private var estimatedProgressObservation: NSKeyValueObservation?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        observeEstimatedProgress()
        setupAccessibility()

        if presenter == nil {
            presenter = WebViewPresenter(view: self)
        }

        presenter?.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        estimatedProgressObservation = nil
    }

    // MARK: - IBActions

    @IBAction private func didTapBackButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

// MARK: - Setup

private extension WebViewViewController {
    func setupWebView() {
        webView.navigationDelegate = self
    }

    func observeEstimatedProgress() {
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [.new]
        ) { [weak self] _, change in
            guard
                let self,
                let newValue = change.newValue
            else { return }

            self.presenter?.didUpdateProgress(newValue)
        }
    }

    func setupAccessibility() {
        webView.accessibilityIdentifier = "UnsplashWebView"
    }
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        presenter?.didRequestAuthCode(for: navigationAction.request) { [weak self] code in
            guard let self else {
                decisionHandler(.allow)
                return
            }

            if let code {
                self.delegate?.webViewViewController(self, didAuthenticateWithCode: code)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        presenter?.didUpdateProgress(webView.estimatedProgress)
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        print("[WebViewViewController.webView.didFail]: navigation error - \(error.localizedDescription)")
        presenter?.didUpdateProgress(webView.estimatedProgress)
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        print("[WebViewViewController.webView.didFailProvisionalNavigation]: provisional navigation error - \(error.localizedDescription)")
        presenter?.didUpdateProgress(webView.estimatedProgress)
    }
}

// MARK: - WebViewViewProtocol

extension WebViewViewController: WebViewViewProtocol {
    func load(request: URLRequest) {
        webView.load(request)
    }

    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}
