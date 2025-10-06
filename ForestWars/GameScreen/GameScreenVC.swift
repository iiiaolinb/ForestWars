//
//  ViewController.swift
//  ForestWars
//
//  Created by Егор Худяев on 30.09.2025.
//

import UIKit

class GameScreenVC: UIViewController {
    
    // MARK: - Properties
    private let viewModel = GameScreenVM()
    private let gameFieldView = GameFieldView()
    private var isGameFieldInitialized = false
    
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
        setupViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Инициализируем игровое поле после того, как GameFieldView создаст ячейки
        if !isGameFieldInitialized && gameFieldView.getCell(at: 0, column: 0) != nil {
            viewModel.initializeGameField()
            isGameFieldInitialized = true
        }
    }
    
    // MARK: - Setup
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Настройка игрового поля
        gameFieldView.delegate = self
        gameFieldView.translatesAutoresizingMaskIntoConstraints = false
        gameFieldView.backgroundColor = .clear
        
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
        viewModel.resetField()
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
        // Передаем событие в ViewModel
        viewModel.cellTapped(at: row, column: column)
    }
}

// MARK: - GameScreenVMDelegate
extension GameScreenVC: GameScreenVMDelegate {
    func didUpdateCell(at row: Int, column: Int, cellType: CellType, number: String, imageName: String) {
        // Обновляем UI ячейки через GameFieldView
        if let cell = gameFieldView.getCell(at: row, column: column) {
            cell.cellType = cellType
            cell.setNumber(number)
            cell.setImage(named: imageName)
        } else {
            print("GameScreenVC: Ячейка [\(row), \(column)] еще не создана, пропускаем обновление")
        }
    }
    
    func didUpdateCellSelection(at row: Int, column: Int, isSelected: Bool) {
        // Обновляем состояние выбора ячейки
        if let cell = gameFieldView.getCell(at: row, column: column) {
            cell.isSelected = isSelected
        }
    }
    
    func didResetField() {
        // Сбрасываем поле через GameFieldView
        gameFieldView.resetField()
    }
    
    func didSelectCell(at row: Int, column: Int, cellType: CellType, number: String, isSelected: Bool) {
        // Убрали индивидуальные логи - теперь используется только общий вывод в didUpdateSelectedCellsCount
    }
    
    func didUpdateSelectedCellsCount(_ count: Int) {
        if count == 0 {
            print("Нет выбранных ячеек")
        } else {
            print("Выбрано ячеек: \(count)")
            print(viewModel.getSelectedCellsInfo())
        }
    }
}

