//
//  ViewController.swift
//  ForestWars
//
//  Created by Егор Худяев on 30.09.2025.
//

import UIKit

class GameScreenVC: UIViewController {
    
    // MARK: - Properties
    private let gameFieldView = GameFieldView()
    
    private let resetButton: ButtonAssistent = {
        let button = ButtonAssistent(
            title: Constants.Text.resetButtonTitle,
            imageName: Constants.SystemImages.resetIcon,
            color: Constants.Colors.resetButtonColor
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let closeButton: ButtonAssistent = {
        let button = ButtonAssistent(
            title: Constants.Text.closeButtonTitle,
            imageName: Constants.SystemImages.closeIcon,
            color: Constants.Colors.closeButtonColor
        )
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
        
        // Настройка кнопок
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        // Добавление subviews
        view.addSubview(gameFieldView)
        view.addSubview(resetButton)
        view.addSubview(closeButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Игровое поле с фиксированными отступами
            gameFieldView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.GameField.topMargin),
            gameFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.GameField.horizontalMargin),
            gameFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.GameField.horizontalMargin),
            gameFieldView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.GameField.bottomMargin),
            
            // Кнопки под полем в одну линию
            resetButton.topAnchor.constraint(equalTo: gameFieldView.bottomAnchor, constant: Constants.GameButtons.topMargin),
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.GameButtons.horizontalMargin),
            resetButton.widthAnchor.constraint(equalToConstant: Constants.GameButtons.width),
            
            // Кнопка закрытия справа от кнопки сброса
            closeButton.topAnchor.constraint(equalTo: gameFieldView.bottomAnchor, constant: Constants.GameButtons.topMargin),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.GameButtons.horizontalMargin),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.GameButtons.width)
        ])
    }
    
    // MARK: - Actions
    @objc private func resetButtonTapped() {
        gameFieldView.resetField()
        print("Field reset!")
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Lifecycle
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            print("GameScreenVC: Игровой экран будет закрыт")
        }
    }
    
    deinit {
        print("GameScreenVC: Игровой экран деинициализирован")
    }
}

// MARK: - GameFieldViewDelegate
extension GameScreenVC: GameFieldViewDelegate {
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

