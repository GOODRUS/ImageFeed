//
//  ImagesListPresenterProtocol.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 25.01.2026.
//

import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    
    func viewDidLoad()
    func numberOfRows() -> Int
    func photo(at index: Int) -> Photo
    func didTapLike(
        at index: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func willDisplayCell(at index: Int)
}
