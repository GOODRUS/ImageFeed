//
//  WebViewViewProtocol.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 21.01.2026.
//

import Foundation

// MARK: - WebViewViewProtocol

protocol WebViewViewProtocol: AnyObject {
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}
