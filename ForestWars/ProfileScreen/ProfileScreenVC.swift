//
//  ProfileScreen.swift
//  ForestWars
//
//  Created by Егор Худяев on 02.10.2025.
//

import UIKit

class ProfileScreenVC: UIViewController {
    
    // MARK: - Properties
    private var profileStackView: UIStackView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Profile"
        
        setupNavigationBar()
        setupProfileContent()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeButtonTapped)
        )
    }
    
    private func setupProfileContent() {
        let titleLabel = UILabel()
        titleLabel.text = "Users profile"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Здесь будет информация о профиле игрока"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        profileStackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        profileStackView.axis = .vertical
        profileStackView.spacing = 20
        profileStackView.alignment = .center
        profileStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(profileStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            profileStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            profileStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        print("ProfileScreenVC: Закрытие экрана профиля")
        dismiss(animated: true)
    }
    
    // MARK: - Lifecycle
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            print("ProfileScreenVC: Экран профиля будет закрыт")
        }
    }
    
    deinit {
        print("ProfileScreenVC: Экран профиля деинициализирован")
    }
}
