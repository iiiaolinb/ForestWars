//
//  SettingsScreen.swift
//  ForestWars
//
//  Created by Егор Худяев on 02.10.2025.
//

import UIKit

class SettingsScreenVC: UIViewController {
    
    // MARK: - Properties
    private var settingsStackView: UIStackView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Settings"
        
        setupNavigationBar()
        setupSettingsContent()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeButtonTapped)
        )
    }
    
    private func setupSettingsContent() {
        let titleLabel = UILabel()
        titleLabel.text = "Apps settings"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Здесь будут настройки игры"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        settingsStackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        settingsStackView.axis = .vertical
        settingsStackView.spacing = 20
        settingsStackView.alignment = .center
        settingsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(settingsStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            settingsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            settingsStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            settingsStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        print("SettingsScreenVC: Закрытие экрана настроек")
        dismiss(animated: true)
    }
    
    // MARK: - Lifecycle
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            print("SettingsScreenVC: Экран настроек будет закрыт")
        }
    }
    
    deinit {
        print("SettingsScreenVC: Экран настроек деинициализирован")
    }
}
