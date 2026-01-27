//
//  WebViewPresenterTests.swift
//  ImageFeedTests
//
//  Created by Дмитрий Шиляев on 22.01.2026.
//

import XCTest
@testable import ImageFeed

final class WebViewPresenterTests: XCTestCase {

    // MARK: - Mocks

    private final class WebViewViewSpy: WebViewViewProtocol {
        var loadedRequest: URLRequest?
        var progressValues: [Float] = []
        var hiddenStates: [Bool] = []

        func load(request: URLRequest) {
            loadedRequest = request
        }

        func setProgressValue(_ newValue: Float) {
            progressValues.append(newValue)
        }

        func setProgressHidden(_ isHidden: Bool) {
            hiddenStates.append(isHidden)
        }
    }

    private final class WebViewHelperStub: WebViewHelperProtocol {
        var requestToReturn: URLRequest?
        var codeToReturn: String?

        func makeAuthRequest() -> URLRequest? {
            requestToReturn
        }

        func code(from url: URL) -> String? {
            codeToReturn
        }
    }

    // MARK: - Tests

    func test_viewDidLoad_callsLoadRequestOnView() {
        let view = WebViewViewSpy()
        let helper = WebViewHelperStub()
        helper.requestToReturn = URLRequest(url: URL(string: "https://example.com")!)
        let presenter = WebViewPresenter(view: view, helper: helper)

        presenter.viewDidLoad()

        XCTAssertNotNil(view.loadedRequest, "View should receive a request on viewDidLoad")
        XCTAssertEqual(
            view.loadedRequest?.url?.absoluteString,
            "https://example.com"
        )
    }

    func test_didUpdateProgress_updatesProgressAndVisibility() {
        let view = WebViewViewSpy()
        let helper = WebViewHelperStub()
        let presenter = WebViewPresenter(view: view, helper: helper)

        presenter.didUpdateProgress(0.5)

        guard let lastProgress = view.progressValues.last else {
            XCTFail("No progress values recorded")
            return
        }

        XCTAssertEqual(lastProgress, 0.5, accuracy: 0.0001)
        XCTAssertEqual(view.hiddenStates.last, false)
    }

    func test_didUpdateProgress_hidesProgressWhenComplete() {
        let view = WebViewViewSpy()
        let helper = WebViewHelperStub()
        let presenter = WebViewPresenter(view: view, helper: helper)

        presenter.didUpdateProgress(1.0)

        guard let lastProgress = view.progressValues.last else {
            XCTFail("No progress values recorded")
            return
        }

        XCTAssertEqual(lastProgress, 1.0, accuracy: 0.0001)
        XCTAssertEqual(view.hiddenStates.last, true)
    }

    func test_didRequestAuthCode_returnsCodeFromHelper() {
        let view = WebViewViewSpy()
        let helper = WebViewHelperStub()
        helper.codeToReturn = "test_code"
        let presenter = WebViewPresenter(view: view, helper: helper)

        let url = URL(string: "https://unsplash.com/oauth/authorize/native?code=test_code")!
        let request = URLRequest(url: url)
        let expectation = expectation(description: "completion called")

        presenter.didRequestAuthCode(for: request) { code in
            XCTAssertEqual(code, "test_code")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_didRequestAuthCode_returnsNilWhenNoURL() {
        let view = WebViewViewSpy()
        let helper = WebViewHelperStub()
        let presenter = WebViewPresenter(view: view, helper: helper)

        var request = URLRequest(url: URL(string: "about:blank")!)
        request.url = nil

        let expectation = expectation(description: "completion called")

        presenter.didRequestAuthCode(for: request) { code in
            XCTAssertNil(code)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
