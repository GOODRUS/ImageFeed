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
        imageView.image = UIImage(named: Constants.avatarImageName)
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constants.nameText
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constants.descriptionText
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constants.loginNameText
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: Constants.logoutButtonImageName)
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
            
            avatarImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.avatarLeading),
            avatarImageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Constants.avatarTop),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            
            // Avatar Image View
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: Constants.nameTopOffset),
            safeArea.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: Constants.trailingOffset),
            
            // Name Label
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constants.loginNameTopOffset),
            
            // Login Name Label
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: Constants.descriptionTopOffset),
            
            // Description Label
            logoutButton.widthAnchor.constraint(equalToConstant: Constants.logoutButtonSize),
            logoutButton.heightAnchor.constraint(equalToConstant: Constants.logoutButtonSize),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            safeArea.trailingAnchor.constraint(equalTo: logoutButton.trailingAnchor, constant: Constants.trailingOffset)
        ])
    }
}

private enum Constants {
    static let avatarCornerRadius: CGFloat = 35
    static let avatarSize: CGFloat = 70
    static let avatarLeading: CGFloat = 16
    static let avatarTop: CGFloat = 32
    static let avatarImageName = "avatar"

    static let nameText = "Екатерина Новикова"
    static let nameFontSize: CGFloat = 23
    static let nameTopOffset: CGFloat = 8

    static let loginNameText = "Hello World!"
    static let loginFontSize: CGFloat = 16
    static let loginNameTopOffset: CGFloat = 8

    static let descriptionText = "@ekaterina_nov"
    static let descriptionFontSize: CGFloat = 16
    static let descriptionTopOffset: CGFloat = 8

    static let logoutButtonImageName = "logout_button"
    static let logoutButtonSize: CGFloat = 44

    static let trailingOffset: CGFloat = 16

    static let backgroundColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1) // #1A1B22
}
