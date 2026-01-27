//
//  ProfileViewControllerTests.swift
//  ProfileViewControllerTests
//
//  Created by Дмитрий Шиляев on 25.01.2026.
//

import XCTest
@testable import ImageFeed

final class ProfileViewControllerTests: XCTestCase {

    private final class ProfilePresenterSpy: ProfilePresenterProtocol {
        private(set) var viewDidLoadCalled = false
        private(set) var didTapLogoutCalled = false
        private(set) var didConfirmLogoutCalled = false

        func viewDidLoad() {
            viewDidLoadCalled = true
        }

        func didTapLogout() {
            didTapLogoutCalled = true
        }

        func didConfirmLogout() {
            didConfirmLogoutCalled = true
        }
    }

    func test_viewDidLoad_callsPresenterViewDidLoad() {
        let sut = ProfileViewController()
        let presenterSpy = ProfilePresenterSpy()
        sut.configure(presenterSpy)

        _ = sut.view  
        sut.viewDidLoad()

        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }

    func test_didTapLogout_callsPresenterDidTapLogout() {
        let sut = ProfileViewController()
        let presenterSpy = ProfilePresenterSpy()
        sut.configure(presenterSpy)

        _ = sut.view

        let logoutButton = sut.view.subviews.compactMap { $0 as? UIButton }
            .first { $0.accessibilityIdentifier == "LogoutButton" }

        logoutButton?.sendActions(for: .touchUpInside)

        XCTAssertTrue(presenterSpy.didTapLogoutCalled)
    }
}
