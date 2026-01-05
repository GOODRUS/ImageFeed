//
//  ImageFeed
//
//  Created by Дмитрий Шиляев on 11.11.2025.
//

import UIKit
import Kingfisher

// MARK: - ProfileViewController

final class ProfileViewController: UIViewController {

    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?

    // MARK: - UI Elements

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: Constant.avatarImageName)
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constant.nameText
        label.font = UIFont.systemFont(ofSize: Constant.nameFontSize, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constant.loginNameText
        label.font = UIFont.systemFont(ofSize: Constant.loginFontSize)
        label.textColor = UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constant.descriptionText
        label.font = UIFont.systemFont(ofSize: Constant.descriptionFontSize)
        label.textColor = .white
        return label
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: Constant.logoutButtonImageName)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(red: 0.961, green: 0.420, blue: 0.424, alpha: 1)
        button.accessibilityIdentifier = "LogoutButton"
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constant.backgroundColor

        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            view.addSubview($0)
        }

        setupConstraints()
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)

        updateProfileDetails()

        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateAvatar()
            }

        updateAvatar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
    }

    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Actions

    @objc private func didTapLogoutButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )

        // Левая кнопка — "Нет" (отмена)
        let noAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)

        // Правая кнопка — "Да" (подтверждение выхода)
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.performLogout()
        }

        alert.addAction(noAction)
        alert.addAction(yesAction)

        present(alert, animated: true)
    }

    private func performLogout() {
        // 1. Чистим токен, данные профиля, аватар, список фотографий, куки WebView
        ProfileLogoutService.shared.logout()
        // 2. Возвращаемся на стартовый экран (SplashViewController)
        switchToSplashScreen()
    }

    private func switchToSplashScreen() {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else {
            assertionFailure("Unable to get key window for logout")
            return
        }

        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()
    }

    // MARK: - Private Methods

    private func updateProfileDetails() {
        guard let profile = profileService.profile else { return }
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }

    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { return }

        let placeholderPointSize = CGFloat(Constant.avatarSize)
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(
                UIImage.SymbolConfiguration(
                    pointSize: placeholderPointSize,
                    weight: .regular,
                    scale: .large
                )
            )

        let processor = RoundCornerImageProcessor(cornerRadius: avatarImageView.bounds.width / 2)
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: imageUrl,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ]
        ) { result in
            switch result {
            case .success(let value):
                print("[ProfileViewController.updateAvatar]: success, cacheType = \(value.cacheType), source = \(value.source)")
            case .failure(let error):
                print("[ProfileViewController.updateAvatar]: failure: \(error.localizedDescription)")
            }
        }
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constant.avatarLeading),
            avatarImageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Constant.avatarTop),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constant.avatarSize),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: Constant.nameTopOffset),
            safeArea.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: Constant.trailingOffset),

            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constant.loginNameTopOffset),

            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: Constant.descriptionTopOffset),

            logoutButton.widthAnchor.constraint(equalToConstant: Constant.logoutButtonSize),
            logoutButton.heightAnchor.constraint(equalToConstant: Constant.logoutButtonSize),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            safeArea.trailingAnchor.constraint(equalTo: logoutButton.trailingAnchor, constant: Constant.trailingOffset)
        ])
    }
}

// MARK: - Constants

private enum Constant {
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
