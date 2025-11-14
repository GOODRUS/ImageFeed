//
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 11.11.2025.
//

import UIKit

// MARK: - ProfileViewController

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.image = UIImage(named: "avatar")
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, World!"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "logout_button")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(red: 0.961, green: 0.420, blue: 0.424, alpha: 1)
        button.accessibilityIdentifier = "LogoutButton"
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        
        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            view.addSubview($0)
        }
        
        setupConstraints()
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didTapLogoutButton() {}
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            
            avatarImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 32),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            safeArea.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 16),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            safeArea.trailingAnchor.constraint(equalTo: logoutButton.trailingAnchor, constant: 16)
        ])
    }
}
