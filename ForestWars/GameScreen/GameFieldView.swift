//
//  GameFieldView.swift
//  ForestWars
//
//  Created by Егор Худяев on 30.09.2025.
//

import UIKit

protocol GameFieldViewDelegate: AnyObject {
    func gameFieldCellTapped(at row: Int, column: Int, cell: CustomSquareButton)
}

class GameFieldView: UIView {
    
    // MARK: - Properties
    weak var delegate: GameFieldViewDelegate?
    
    private var cells: [[CustomSquareButton]] = []
    private var buttonSize: CGFloat = 0
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = Constants.GameField.cellSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeCellsArray()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeCellsArray()
        setupView()
    }
    
    // MARK: - Setup
    private func initializeCellsArray() {
        // Инициализируем пустой массив ячеек
        cells = []
    }
    
    private func setupView() {
        backgroundColor = .clear
        addSubview(stackView)
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateButtonSizes()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func createGrid() {
        // Очищаем существующие subviews
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Создаем массив для хранения кнопок
        cells = Array(repeating: Array(repeating: CustomSquareButton(), count: Constants.GameField.gridWidth), count: Constants.GameField.gridHeight)
        
        // Создаем строки
        for row in 0..<Constants.GameField.gridHeight {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fillEqually
            rowStackView.alignment = .fill
            rowStackView.spacing = Constants.GameField.cellSpacing
            
            // Создаем кнопки для каждой строки
            for column in 0..<Constants.GameField.gridWidth {
                let cell = CustomSquareButton()
                cell.delegate = self
                cell.translatesAutoresizingMaskIntoConstraints = false
                
                // Инициализируем ячейку с дефолтными значениями
                // Данные будут установлены через GameScreenVM
                cell.cellType = .neutral
                cell.setNumber(Constants.CellType.neutralNumber)
                cell.setImage(named: Constants.SystemImages.neutral)
                
                // Сохраняем позицию в теге (row * width + column)
                cell.tag = row * Constants.GameField.gridWidth + column
                
                cells[row][column] = cell
                rowStackView.addArrangedSubview(cell)
            }
            
            stackView.addArrangedSubview(rowStackView)
        }
    }
    
    private func updateButtonSizes() {
        guard bounds.width > 0 && bounds.height > 0 else { return }
        
        let newButtonSize = Constants.GameField.calculateButtonSize(for: bounds.size)
        
        // Создаем сетку только если размер изменился или сетка еще не создана
        if newButtonSize != buttonSize || cells.isEmpty {
            buttonSize = newButtonSize
            createGrid()
            updateAllButtonConstraints()
        }
    }
    
    private func updateAllButtonConstraints() {
        for row in 0..<Constants.GameField.gridHeight {
            for column in 0..<Constants.GameField.gridWidth {
                let cell = cells[row][column]
                
                // Удаляем старые constraints
                cell.removeFromSuperview()
                cell.translatesAutoresizingMaskIntoConstraints = false
                
                // Находим соответствующий rowStackView и добавляем кнопку обратно
                if let rowStackView = stackView.arrangedSubviews[row] as? UIStackView {
                    rowStackView.addArrangedSubview(cell)
                }
                
                // Устанавливаем новые constraints
                NSLayoutConstraint.activate([
                    cell.widthAnchor.constraint(equalToConstant: buttonSize),
                    cell.heightAnchor.constraint(equalToConstant: buttonSize)
                ])
            }
        }
    }
    
    // MARK: - Public Methods
    func getCell(at row: Int, column: Int) -> CustomSquareButton? {
        guard row >= 0 && row < Constants.GameField.gridHeight &&
              column >= 0 && column < Constants.GameField.gridWidth &&
              !cells.isEmpty && row < cells.count && column < cells[row].count else {
            return nil
        }
        return cells[row][column]
    }
    
    func resetField() {
        // Сброс только визуального состояния ячеек
        // Логика генерации новых ячеек теперь в ViewModel
        for row in 0..<Constants.GameField.gridHeight {
            for column in 0..<Constants.GameField.gridWidth {
                let cell = cells[row][column]
                cell.isSelected = false
            }
        }
    }
    
    func getSelectedCells() -> [(row: Int, column: Int, cell: CustomSquareButton)] {
        var selectedCells: [(row: Int, column: Int, cell: CustomSquareButton)] = []
        
        for row in 0..<Constants.GameField.gridHeight {
            for column in 0..<Constants.GameField.gridWidth {
                let cell = cells[row][column]
                if cell.isSelected {
                    selectedCells.append((row: row, column: column, cell: cell))
                }
            }
        }
        
        return selectedCells
    }
    
    // MARK: - Private Methods
    private func getRandomCellType() -> CellType {
        let types: [CellType] = [.enemy, .ally, .neutral]
        return types.randomElement() ?? .neutral
    }
    
    private func getNumberForCellType(_ type: CellType) -> String {
        switch type {
        case .enemy:
            return Constants.CellType.enemyNumber
        case .ally:
            return Constants.CellType.allyNumber
        case .neutral:
            return Constants.CellType.neutralNumber
        }
    }
    
    private func getImageNameForCellType(_ type: CellType) -> String {
        switch type {
        case .enemy:
            return Constants.SystemImages.enemy
        case .ally:
            return Constants.SystemImages.ally
        case .neutral:
            return Constants.SystemImages.neutral
        }
    }
    
    private func getPositionFromTag(_ tag: Int) -> (row: Int, column: Int) {
        let row = tag / Constants.GameField.gridWidth
        let column = tag % Constants.GameField.gridWidth
        return (row: row, column: column)
    }
}

// MARK: - CustomSquareButtonDelegate
extension GameFieldView: CustomSquareButtonDelegate {
    func customSquareButtonTapped(_ button: CustomSquareButton) {
        let position = getPositionFromTag(button.tag)
        delegate?.gameFieldCellTapped(at: position.row, column: position.column, cell: button)
    }
}
