//
//  WebViewHelper.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 21.01.2026.
//

import Foundation

// MARK: - WebViewHelperProtocol

protocol WebViewHelperProtocol {
    func makeAuthRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

// MARK: - WebViewHelper

struct WebViewHelper: WebViewHelperProtocol {

    let configuration: AuthConfiguration

    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }

    func makeAuthRequest() -> URLRequest? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]

        guard let url = urlComponents.url else {
            return nil
        }

        return URLRequest(url: url)
    }

    func code(from url: URL) -> String? {
        guard
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        else {
            return nil
        }

        return codeItem.value
    }
}
