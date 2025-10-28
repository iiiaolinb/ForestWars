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
    
    //MARK: - UI elements
    
    private let leftInfoStack = TopInfoLabelAssistent(infoLabelType: .ally)
    private let centerTimer = TopTimerAssistent()
    private let rightInfoStack = TopInfoLabelAssistent(infoLabelType: .enemy)
    
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
    
    // MARK: - Setup
    private func setupViewModel() {
        viewModel.delegate = self
        centerTimer.delegate = self
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        gameFieldView.delegate = self
        gameFieldView.translatesAutoresizingMaskIntoConstraints = false
        
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(leftInfoStack)
        view.addSubview(centerTimer)
        view.addSubview(rightInfoStack)
        view.addSubview(gameFieldView)
        view.addSubview(resetButton)
        view.addSubview(closeButton)
        
        leftInfoStack.translatesAutoresizingMaskIntoConstraints = false
        centerTimer.translatesAutoresizingMaskIntoConstraints = false
        rightInfoStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints
        NSLayoutConstraint.activate([
            leftInfoStack.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.InfoLabel.topMargin),
            leftInfoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.InfoLabel.horizontalMargin),
            leftInfoStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3),
            leftInfoStack.heightAnchor.constraint(equalToConstant: Constants.InfoLabel.height),
            
            centerTimer.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.InfoLabel.topMargin),
            centerTimer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerTimer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25),
            centerTimer.heightAnchor.constraint(equalToConstant: Constants.InfoLabel.height),
            
            rightInfoStack.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.InfoLabel.topMargin),
            rightInfoStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.InfoLabel.horizontalMargin),
            rightInfoStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3),
            rightInfoStack.heightAnchor.constraint(equalToConstant: Constants.InfoLabel.height),
            
            // Игровое поле с фиксированными отступами
            gameFieldView.topAnchor.constraint(equalTo: leftInfoStack.bottomAnchor, constant: Constants.GameField.topMargin),
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
    
    // MARK: - Timer Management
    
    /// Запускает таймер с заданным временем
    /// - Parameter timeInSeconds: Время в секундах для отсчета
    func startGameTimer(timeInSeconds: TimeInterval) {
        centerTimer.startTimer(timeInSeconds: timeInSeconds)
    }
    
    /// Останавливает таймер
    func stopGameTimer() {
        centerTimer.stopTimer()
    }
    
    /// Сбрасывает таймер на начальное значение
    func resetGameTimer() {
        centerTimer.resetTimer()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didUpdateInfoStack()
        
        // Запускаем таймер на 30 секунд для демонстрации
        startGameTimer(timeInSeconds: 30)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            print("GameScreenVC: Игровой экран будет закрыт")
        }
    }
    
    deinit {
        print("GameScreenVC: Игровой экран деинициализирован")
    }
    
    // MARK: - Private Methods
    private func updateUnitsInfo() {
        let allyUnits = viewModel.getTotalUnits(of: .ally)
        let enemyUnits = viewModel.getTotalUnits(of: .enemy)
        
        leftInfoStack.updateUnits(count: allyUnits)
        rightInfoStack.updateUnits(count: enemyUnits)
    }
    
    private func updateBuildingsInfo() {
        let allyUnits = viewModel.getTotalBuildings(of: .ally)
        let enemyUnits = viewModel.getTotalBuildings(of: .enemy)
        
        leftInfoStack.updateBuildings(count: allyUnits)
        rightInfoStack.updateBuildings(count: enemyUnits)
    }
    
    private func startGameFieldInitializationIfNeeded() {
        guard !isGameFieldInitialized else { return }
        isGameFieldInitialized = true
        print("[GameScreenVC] Grid is ready — initializing ViewModel")
        
        // 1. Инициализируем игровое поле через ViewModel
        viewModel.initializeGameField()
        
        // 2. Анимация появления всех ячеек
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            for row in 0..<Constants.GameField.gridHeight {
                for column in 0..<Constants.GameField.gridWidth {
                    gameFieldView.addCellWithAppearAnimation(row: row, column: column)
                }
            }
        }
    }
}

// MARK: - GameFieldViewDelegate
extension GameScreenVC: GameFieldViewDelegate {
    func gameFieldDidFinishCreatingGrid() {
        startGameFieldInitializationIfNeeded()
    }
    
    func gameFieldCellTapped(at row: Int, column: Int, cell: CustomSquareButton) {
        viewModel.cellTapped(at: row, column: column)
    }
    
    func gameFieldCellDoubleTapped(at row: Int, column: Int, cell: CustomSquareButton) {
        viewModel.cellDoubleTapped(at: row, column: column)
    }
}

// MARK: - GameScreenVMDelegate
extension GameScreenVC: GameScreenVMDelegate {
    func didUpdateCell(at row: Int, column: Int, cellType: CellType, number: Int, buiding: Int, imageName: String) {
        // Обновляем UI ячейки через GameFieldView
        if let cell = gameFieldView.getCell(at: row, column: column) {
            
            cell.cellType = cellType
            cell.setNumber(number)
            cell.setBuidings(buiding)
            cell.setImage(named: imageName)
        } else {
            print("GameScreenVC: Ячейка [\(row), \(column)] еще не создана, пропускаем обновление")
        }
    }
    
    func didUpdateCellSelection(at row: Int, column: Int, isSelected: Bool) {
        // Обновляем состояние выбора ячейки
        if let cell = gameFieldView.getCell(at: row, column: column) {
            cell.setSelected(isSelected)
        }
    }
    
    func didResetField() {
        gameFieldView.resetField()
        didUpdateInfoStack()
    }
    
    func didSelectCell(at row: Int, column: Int, cellType: CellType, number: Int, isSelected: Bool) {
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
    
    func didStartUnitMovementAnimation(at row: Int, column: Int) {
        if let cell = gameFieldView.getCell(at: row, column: column) {
            cell.startUnitMovementAnimation()
        }
    }
    
    func didStartDoubleTapExplosionAnimation(at row: Int, column: Int) {
        if let cell = gameFieldView.getCell(at: row, column: column) {
            cell.playDoubleTapExplosionAnimation()
        }
    }
    
    func didCompleteUnitMovement() {
        // Останавливаем анимацию на всех ячейках
        for row in 0..<Constants.GameField.gridHeight {
            for column in 0..<Constants.GameField.gridWidth {
                if let cell = gameFieldView.getCell(at: row, column: column) {
                    cell.stopUnitMovementAnimation()
                }
            }
        }
        
        // После завершения перемещения обновляем счётчики
        didUpdateInfoStack()
    }
    
    func didUpdateInfoStack() {
        updateUnitsInfo()
        updateBuildingsInfo()
    }
}

// MARK: - TopTimerAssistentDelegate
extension GameScreenVC: TopTimerAssistentDelegate {
    func timerDidFinish() {
        print("GameScreenVC: Таймер завершился!")
        // Здесь можно добавить логику завершения игры
        // Например, показать алерт или перейти к экрану результатов
    }
    
    func timerDidUpdate(remainingTime: TimeInterval) {
        // Здесь можно добавить дополнительную логику при обновлении таймера
        // Например, обновление UI или проверка условий игры
        if remainingTime <= 10 {
            print("GameScreenVC: Осталось \(Int(remainingTime)) секунд!")
        }
    }
}
