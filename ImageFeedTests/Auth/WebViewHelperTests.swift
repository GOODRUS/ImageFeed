//
//  WebViewHelperTests.swift
//  ImageFeedTests
//
//  Created by Дмитрий Шиляев on 22.01.2026.
//

import XCTest
@testable import ImageFeed

final class WebViewHelperTests: XCTestCase {

    func test_makeAuthRequest_buildsCorrectURLAndParams() {
        let config = AuthConfiguration(
            authURLString: "https://example.com/oauth/authorize",
            accessKey: "test_access_key",
            redirectURI: "urn:ietf:wg:oauth:2.0:oob",
            accessScope: "public read_user"
        )
        let helper = WebViewHelper(configuration: config)

        let request = helper.makeAuthRequest()
        XCTAssertNotNil(request, "Request should not be nil")

        guard let url = request?.url,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            XCTFail("URL or components should not be nil")
            return
        }

        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, "example.com")
        XCTAssertEqual(components.path, "/oauth/authorize")

        let items = components.queryItems ?? []
        func value(for name: String) -> String? {
            items.first(where: { $0.name == name })?.value
        }

        XCTAssertEqual(value(for: "client_id"), "test_access_key")
        XCTAssertEqual(value(for: "redirect_uri"), "urn:ietf:wg:oauth:2.0:oob")
        XCTAssertEqual(value(for: "response_type"), "code")
        XCTAssertEqual(value(for: "scope"), "public read_user")
    }

    func test_codeFromURL_returnsCode_whenPathAndQueryAreCorrect() {
        let helper = WebViewHelper(configuration: .standard)

        guard let url = URL(string: "https://unsplash.com/oauth/authorize/native?code=abc123") else {
            XCTFail("Failed to create URL")
            return
        }

        let code = helper.code(from: url)
        XCTAssertEqual(code, "abc123")
    }

    func test_codeFromURL_returnsNil_whenPathIsWrong() {
        let helper = WebViewHelper(configuration: .standard)

        guard let url = URL(string: "https://unsplash.com/oauth/authorize/other?code=abc123") else {
            XCTFail("Failed to create URL")
            return
        }

        let code = helper.code(from: url)
        XCTAssertNil(code)
    }

    func test_codeFromURL_returnsNil_whenNoCodeParam() {
        let helper = WebViewHelper(configuration: .standard)

        guard let url = URL(string: "https://unsplash.com/oauth/authorize/native?state=xyz") else {
            XCTFail("Failed to create URL")
            return
        }

        let code = helper.code(from: url)
        XCTAssertNil(code)
    }
}
