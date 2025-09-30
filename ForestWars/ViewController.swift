//
//  ViewController.swift
//  ForestWars
//
//  Created by Егор Худяев on 30.09.2025.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    private let enemyButton = CustomSquareButton()
    private let allyButton = CustomSquareButton()
    private let neutralButton = CustomSquareButton()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = Constants.Layout.stackViewSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Настройка кнопок
        setupButton(enemyButton, type: .enemy, number: Constants.CellType.enemyNumber, imageName: Constants.SystemImages.enemy)
        setupButton(allyButton, type: .ally, number: Constants.CellType.allyNumber, imageName: Constants.SystemImages.ally)
        setupButton(neutralButton, type: .neutral, number: Constants.CellType.neutralNumber, imageName: Constants.SystemImages.neutral)
        
        // Настройка stack view
        stackView.addArrangedSubview(enemyButton)
        stackView.addArrangedSubview(allyButton)
        stackView.addArrangedSubview(neutralButton)
        
        view.addSubview(stackView)
        
        // Constraints для центрирования stack view
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: Constants.Layout.stackViewMargin),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -Constants.Layout.stackViewMargin)
        ])
    }
    
    private func setupButton(_ button: CustomSquareButton, type: CellType, number: String, imageName: String) {
        button.delegate = self
        button.cellType = type
        button.setNumber(number)
        button.setImage(UIImage(systemName: imageName))
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: Constants.Button.size),
            button.heightAnchor.constraint(equalToConstant: Constants.Button.size)
        ])
    }
}

// MARK: - CustomSquareButtonDelegate
extension ViewController: CustomSquareButtonDelegate {
    func customSquareButtonTapped(_ button: CustomSquareButton) {
        let typeString: String
        switch button.cellType {
        case .enemy:
            typeString = Constants.Text.enemyType
        case .ally:
            typeString = Constants.Text.allyType
        case .neutral:
            typeString = Constants.Text.neutralType
        }
        
        let stateString = button.isSelected ? Constants.Text.selectedState : Constants.Text.deselectedState
        print("Кнопка \(stateString)! Тип: \(typeString), Номер: \(button.getNumber())")
    }
}

