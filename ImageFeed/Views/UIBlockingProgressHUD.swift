//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 22.12.2025.
//

import UIKit
import ProgressHUD

// MARK: - UIBlockingProgressHUD

final class UIBlockingProgressHUD {

    // MARK: - Window

    private static var window: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }

    // MARK: - Locking

    private static let lockQueue = DispatchQueue(label: "UIBlockingProgressHUD.lockQueue")

    private static var _lockCount: Int = 0
    private static var lockCount: Int {
        get { lockQueue.sync { _lockCount } }
        set { lockQueue.sync { _lockCount = newValue } }
    }

    // MARK: - Public API

    static func show() {
        lockQueue.sync {
            _lockCount += 1

            guard _lockCount == 1 else { return }

            DispatchQueue.main.async {
                window?.isUserInteractionEnabled = false
                ProgressHUD.animate()
            }
        }
    }

    static func dismiss() {
        lockQueue.sync {
            guard _lockCount > 0 else { return }

            _lockCount -= 1

            guard _lockCount == 0 else { return }

            DispatchQueue.main.async {
                window?.isUserInteractionEnabled = true
                ProgressHUD.dismiss()
            }
        }
    }
}
