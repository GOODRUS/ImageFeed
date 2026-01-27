//
//  ProfilePresenterProtocol.swift
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 25.01.2026.
//

import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapLogout()
    func didConfirmLogout()
}
