//
//  ImagesListViewProtocol.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 25.01.2026.
//

import Foundation

protocol ImagesListViewProtocol: AnyObject {
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
}
