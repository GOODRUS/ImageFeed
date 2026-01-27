//
//  ImagesListViewControllerTests.swift
//  ImagesListViewControllerTests
//
//  Created by Дмитрий Шиляев on 25.01.2026.
//

import XCTest
@testable import ImageFeed

final class ImagesListViewControllerTests: XCTestCase {

    private final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
        private(set) var viewDidLoadCalled = false

        func viewDidLoad() {
            viewDidLoadCalled = true
        }

        func numberOfRows() -> Int {
            return 0
        }

        func photo(at index: Int) -> Photo {
            return Photo(
                id: "",
                size: .zero,
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "",
                largeImageURL: "",
                isLiked: false
            )
        }

        func didTapLike(
            at index: Int,
            completion: @escaping (Result<Void, Error>) -> Void
        ) {
            completion(.success(()))
        }

        func willDisplayCell(at index: Int) {
        }
    }

    func test_viewDidLoad_callsPresenterViewDidLoad() {

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let sut = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController else {
            XCTFail("Failed to load ImagesListViewController from storyboard")
            return
        }

        let presenterSpy = ImagesListPresenterSpy()
        sut.configure(presenterSpy)

        _ = sut.view
        sut.viewDidLoad()

        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
}
