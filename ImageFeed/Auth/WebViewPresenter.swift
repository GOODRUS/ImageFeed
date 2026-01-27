//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 22.01.2026.
//

import Foundation

// MARK: - WebViewPresenterProtocol

protocol WebViewPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didUpdateProgress(_ newValue: Double)
    func didRequestAuthCode(for request: URLRequest, completion: @escaping (String?) -> Void)
}

// MARK: - WebViewPresenter

final class WebViewPresenter: WebViewPresenterProtocol {

    weak var view: WebViewViewProtocol?
    private let helper: WebViewHelperProtocol

    // MARK: - Init

    init(view: WebViewViewProtocol, helper: WebViewHelperProtocol = WebViewHelper()) {
        self.view = view
        self.helper = helper
    }

    // MARK: - WebViewPresenterProtocol

    func viewDidLoad() {
        guard let request = helper.makeAuthRequest() else { return }
        view?.load(request: request)
        updateProgress(0.0)
    }

    func didUpdateProgress(_ newValue: Double) {
        updateProgress(newValue)
    }

    func didRequestAuthCode(
        for request: URLRequest,
        completion: @escaping (String?) -> Void
    ) {
        guard let url = request.url else {
            completion(nil)
            return
        }
        let code = helper.code(from: url)
        completion(code)
    }

    // MARK: - Private

    private func updateProgress(_ value: Double) {
        let clamped = Float(min(max(value, 0.0), 1.0))
        view?.setProgressValue(clamped)
        view?.setProgressHidden(abs(value - 1.0) <= 0.0001)
    }
}
