//
//  ViewController.swift
//  ForestWars
//
//  Created by Егор Худяев on 30.09.2025.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    private let gameFieldView = GameFieldView()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сбросить поле", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Настройка игрового поля
        gameFieldView.delegate = self
        gameFieldView.translatesAutoresizingMaskIntoConstraints = false
        gameFieldView.backgroundColor = .lightGray
        
        // Настройка кнопки сброса
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        // Добавление subviews
        view.addSubview(gameFieldView)
        view.addSubview(resetButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Игровое поле с фиксированными отступами
            gameFieldView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.GameField.topMargin),
            gameFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.GameField.horizontalMargin),
            gameFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.GameField.horizontalMargin),
            gameFieldView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.GameField.bottomMargin),
            
            // Кнопка сброса под полем
            resetButton.topAnchor.constraint(equalTo: gameFieldView.bottomAnchor, constant: 20),
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.widthAnchor.constraint(equalToConstant: 200),
            resetButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions
    @objc private func resetButtonTapped() {
        gameFieldView.resetField()
        print("Поле сброшено!")
    }
}

// MARK: - GameFieldViewDelegate
extension ViewController: GameFieldViewDelegate {
    func gameFieldCellTapped(at row: Int, column: Int, cell: CustomSquareButton) {
        let typeString: String
        switch cell.cellType {
        case .enemy:
            typeString = Constants.Text.enemyType
        case .ally:
            typeString = Constants.Text.allyType
        case .neutral:
            typeString = Constants.Text.neutralType
        }
        
        let stateString = cell.isSelected ? Constants.Text.selectedState : Constants.Text.deselectedState
        print("Ячейка [\(row), \(column)] \(stateString)! Тип: \(typeString), Номер: \(cell.getNumber())")
        
        // Показываем информацию о выбранных ячейках
        let selectedCells = gameFieldView.getSelectedCells()
        print("Всего выбрано ячеек: \(selectedCells.count)")
    }
}

