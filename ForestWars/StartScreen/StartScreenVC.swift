//
//  StartScreen.swift
//  ForestWars
//
//  Created by Егор Худяев on 02.10.2025.
//

import UIKit

class StartScreen: UIViewController {
    
    // MARK: - Properties
    private var buttonsStackView: UIStackView!
    private let viewModel: StartScreenVMProtocol
    
    // MARK: - Initialization
    init(viewModel: StartScreenVMProtocol = StartScreenVM()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupViewModel()
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = StartScreenVM()
        super.init(coder: coder)
        setupViewModel()
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Forest Wars"
        
        setupTitleLabel()
        setupButtons()
        setupConstraints()
    }
    
    private func setupTitleLabel() {
        let titleLabel = UILabel()
        titleLabel.text = "Forest Wars"
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50)
        ])
    }
    
    private func setupButtons() {
        // Создаем кнопки с помощью ButtonAssistant
        let startGameButton = ButtonAssistent(title: "Start game", imageName: "play.fill")
        startGameButton.addTarget(self, action: #selector(startGameTapped), for: .touchUpInside)
        
        let settingsButton = ButtonAssistent(title: "Settings", imageName: "gear")
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        
        let profileButton = ButtonAssistent(title: "Profile", imageName: "person.fill")
        profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
        
        let exitButton = ButtonAssistent(title: "Exit", imageName: "xmark.circle.fill")
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        
        // Создаем вертикальный стек с кнопками
        buttonsStackView = UIStackView(arrangedSubviews: [startGameButton, settingsButton, profileButton, exitButton])
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = 20
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buttonsStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonsStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            buttonsStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    // MARK: - Button Actions
    @objc private func startGameTapped() {
        viewModel.startGame()
    }
    
    @objc private func settingsTapped() {
        viewModel.openSettings()
    }
    
    @objc private func profileTapped() {
        viewModel.openProfile()
    }
    
    @objc private func exitTapped() {
        viewModel.exitApp()
    }
}

// MARK: - StartScreenVMDelegate
extension StartScreen: StartScreenVMDelegate {
    func navigateToGame() {
        let gameVC = GameScreenVC()
        let navigationController = UINavigationController(rootViewController: gameVC)
        
        // Отключаем возможность закрытия смахиванием вниз
        navigationController.isModalInPresentation = true
        
        present(navigationController, animated: true)
    }
    
    func navigateToSettings() {
        let settingsVC = SettingsScreenVC()
        let navigationController = UINavigationController(rootViewController: settingsVC)
        present(navigationController, animated: true)
    }
    
    func navigateToProfile() {
        let profileVC = ProfileScreenVC()
        let navigationController = UINavigationController(rootViewController: profileVC)
        present(navigationController, animated: true)
    }
    
    func exitApplication() {
        // Здесь будет логика выхода из приложения
        // TODO: Реализовать логику выхода из приложения
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
