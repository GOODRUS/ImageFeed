//
//  Image_FeedUITests.swift
//  Image FeedUITests
//
//  Created by Дмитрий Шиляев on 24.01.2026.
//

import XCTest

final class ImageFeedUITests: XCTestCase {

    private let app = XCUIApplication()

    private let testLogin = "Login"
    private let testPassword = "Password"

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    // MARK: - Scenario 1: Auth

    func testAuth() throws {
      
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 10), "Кнопка авторизации не появилась")
        authButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10), "WebView экрана логина не появился")
        
        let emailField = webView.descendants(matching: .textField).element
        XCTAssertTrue(emailField.waitForExistence(timeout: 10), "Поле Email address не найдено")
        
        emailField.tap()
        sleep(1)
        emailField.typeText(testLogin)
        
        webView.swipeUp()
        webView.swipeUp()
        
        let passwordField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordField.waitForExistence(timeout: 10), "Поле Password не найдено")
        
        for _ in 0..<3 {
            passwordField.tap()
            sleep(1)
            if app.keyboards.count > 0 { break }
        }
        
        XCTAssertTrue(app.keyboards.element.waitForExistence(timeout: 5), "Клавиатура для поля Password не появилась")
        
        passwordField.typeText(testPassword)
        
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 10), "Кнопка Login не найдена")
        loginButton.tap()
        
        let feedTable = app.tables["ImagesListTable"]
        XCTAssertTrue(feedTable.waitForExistence(timeout: 20), "Экран ленты не открылся после авторизации")
    }
    
    // MARK: - Scenario 2: Feed

    func testFeed() throws {
        let feedTable = app.tables["ImagesListTable"]
        XCTAssertTrue(feedTable.waitForExistence(timeout: 15), "Экран ленты не открылся")

        feedTable.swipeUp()

        let firstCell = feedTable.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "Первая ячейка ленты не найдена")

        let likeButton = firstCell.buttons["LikeButton"]
        XCTAssertTrue(likeButton.exists, "Кнопка лайка не найдена в первой ячейке")

        likeButton.tap()
        likeButton.tap()

        firstCell.tap()

        let imageScrollView = app.scrollViews["SingleImageScrollView"]
        XCTAssertTrue(imageScrollView.waitForExistence(timeout: 10), "Полноэкранное изображение не открылось")

        imageScrollView.pinch(withScale: 3.0, velocity: 1.0)
        imageScrollView.pinch(withScale: 0.5, velocity: -1.0)

        let backButton = app.buttons["BackButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Кнопка возврата с полноэкранного изображения не найдена")
        backButton.tap()

        XCTAssertTrue(feedTable.waitForExistence(timeout: 5), "После закрытия изображения не вернулись на экран ленты")
    }

    // MARK: - Scenario 3: Profile

    func testProfile() throws {
        let feedTable = app.tables["ImagesListTable"]
        XCTAssertTrue(feedTable.waitForExistence(timeout: 15), "Экран ленты не открылся")

        app.tabBars.buttons.element(boundBy: 1).tap()

        let nameLabel = app.staticTexts["ProfileNameLabel"]
        let loginLabel = app.staticTexts["ProfileLoginLabel"]

        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5), "Имя профиля не отображается")
        XCTAssertTrue(loginLabel.exists, "Логин профиля не отображается")

        let logoutButton = app.buttons["LogoutButton"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5), "Кнопка логаута не найдена")
        logoutButton.tap()

        let yesButton = app.alerts.buttons["Да"]
        XCTAssertTrue(yesButton.waitForExistence(timeout: 5), "Кнопка подтверждения логаута не найдена")
        yesButton.tap()

        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 10), "После логаута не вернулись на экран авторизации")
    }
}
