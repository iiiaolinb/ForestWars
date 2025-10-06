//
//  GameScreenVM.swift
//  ForestWars
//
//  Created by Егор Худяев on 06.10.2025.
//

import UIKit

// MARK: - GameScreenVMDelegate
protocol GameScreenVMDelegate: AnyObject {
    func didUpdateCell(at row: Int, column: Int, cellType: CellType, number: String, imageName: String)
    func didUpdateCellSelection(at row: Int, column: Int, isSelected: Bool)
    func didResetField()
    func didSelectCell(at row: Int, column: Int, cellType: CellType, number: String, isSelected: Bool)
    func didUpdateSelectedCellsCount(_ count: Int)
}

// MARK: - GameScreenVM
class GameScreenVM {
    
    // MARK: - Properties
    weak var delegate: GameScreenVMDelegate?
    
    private var gameField: [[GameCell]] = []
    private let gridWidth: Int = Constants.GameField.gridWidth
    private let gridHeight: Int = Constants.GameField.gridHeight
    
    // MARK: - Initialization
    init() {
        // Инициализация будет вызвана из GameScreenVC после настройки UI
    }
    
    // MARK: - Public Methods
    
    /// Инициализация игрового поля
    func initializeGameField() {
        print("GameScreenVM: Инициализация игрового поля...")
        gameField = []
        
        for row in 0..<gridHeight {
            var rowCells: [GameCell] = []
            for column in 0..<gridWidth {
                let cellType = getRandomCellType()
                let number = getNumberForCellType(cellType)
                let imageName = getImageNameForCellType(cellType)
                
                let cell = GameCell(
                    type: cellType,
                    number: number,
                    imageName: imageName,
                    isSelected: false
                )
                
                rowCells.append(cell)
                delegate?.didUpdateCell(at: row, column: column, cellType: cellType, number: number, imageName: imageName)
            }
            gameField.append(rowCells)
        }
        print("GameScreenVM: Игровое поле инициализировано")
    }
    
    /// Сброс игрового поля
    func resetField() {
        // Сначала снимаем выбор со всех ячеек
        deselectAllCells()
        
        for row in 0..<gridHeight {
            for column in 0..<gridWidth {
                let cellType = getRandomCellType()
                let number = getNumberForCellType(cellType)
                let imageName = getImageNameForCellType(cellType)
                
                gameField[row][column] = GameCell(
                    type: cellType,
                    number: number,
                    imageName: imageName,
                    isSelected: false
                )
                
                delegate?.didUpdateCell(at: row, column: column, cellType: cellType, number: number, imageName: imageName)
            }
        }
        
        delegate?.didResetField()
        updateSelectedCellsCount()
    }
    
    /// Обработка нажатия на ячейку
    func cellTapped(at row: Int, column: Int) {
        guard isValidPosition(row: row, column: column) else { return }
        
        let cell = gameField[row][column]
        
        // Если ячейка уже выбрана, отменяем выбор
        if cell.isSelected {
            deselectAllCells()
        } else {
            // Сначала снимаем выбор со всех других ячеек
            deselectAllCells()
            
            // Выбираем центральную ячейку и её соседей
            selectCellAndNeighbors(at: row, column: column)
        }
        
        updateSelectedCellsCount()
    }
    
    /// Получение информации о ячейке
    func getCell(at row: Int, column: Int) -> GameCell? {
        guard isValidPosition(row: row, column: column) else { return nil }
        return gameField[row][column]
    }
    
    /// Получение всех выбранных ячеек
    func getSelectedCells() -> [(row: Int, column: Int, cell: GameCell)] {
        var selectedCells: [(row: Int, column: Int, cell: GameCell)] = []
        
        for row in 0..<gridHeight {
            for column in 0..<gridWidth {
                let cell = gameField[row][column]
                if cell.isSelected {
                    selectedCells.append((row: row, column: column, cell: cell))
                }
            }
        }
        
        return selectedCells
    }
    
    /// Получение количества выбранных ячеек
    func getSelectedCellsCount() -> Int {
        return getSelectedCells().count
    }
    
    /// Получение текущей выбранной ячейки (центральная ячейка)
    func getCurrentSelectedCell() -> (row: Int, column: Int, cell: GameCell)? {
        let selectedCells = getSelectedCells()
        return selectedCells.first
    }
    
    /// Получение информации о всех выбранных ячейках для отладки
    func getSelectedCellsInfo() -> String {
        let selectedCells = getSelectedCells()
        var info = "Выбранные ячейки (всего: \(selectedCells.count)):\n"
        
        for (index, (row, column, cell)) in selectedCells.enumerated() {
            let typeString = getTypeString(for: cell.type)
            let isSelectedStatus = cell.isSelected ? "✓" : "✗"
            info += "\(index + 1). [\(row), \(column)] - \(typeString) (\(cell.number)) [\(isSelectedStatus)]\n"
        }
        
        return info
    }
    
    /// Получение строкового представления типа ячейки
    private func getTypeString(for type: CellType) -> String {
        switch type {
        case .enemy:
            return Constants.Text.enemyType
        case .ally:
            return Constants.Text.allyType
        case .neutral:
            return Constants.Text.neutralType
        }
    }
    
    /// Получение типа ячейки по строке и столбцу
    func getCellType(at row: Int, column: Int) -> CellType? {
        guard isValidPosition(row: row, column: column) else { return nil }
        return gameField[row][column].type
    }
    
    /// Получение номера ячейки по строке и столбцу
    func getCellNumber(at row: Int, column: Int) -> String? {
        guard isValidPosition(row: row, column: column) else { return nil }
        return gameField[row][column].number
    }
    
    /// Получение имени изображения ячейки по строке и столбцу
    func getCellImageName(at row: Int, column: Int) -> String? {
        guard isValidPosition(row: row, column: column) else { return nil }
        return gameField[row][column].imageName
    }
    
    /// Проверка, выбрана ли ячейка
    func isCellSelected(at row: Int, column: Int) -> Bool {
        guard isValidPosition(row: row, column: column) else { return false }
        return gameField[row][column].isSelected
    }
    
    // MARK: - Private Methods
    
    /// Проверка валидности позиции
    private func isValidPosition(row: Int, column: Int) -> Bool {
        return row >= 0 && row < gridHeight && column >= 0 && column < gridWidth
    }
    
    /// Получение случайного типа ячейки
    private func getRandomCellType() -> CellType {
        let types: [CellType] = [.enemy, .ally, .neutral]
        return types.randomElement() ?? .neutral
    }
    
    /// Получение номера для типа ячейки
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
    
    /// Получение имени изображения для типа ячейки
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
    
    /// Выбор ячейки и её соседей
    private func selectCellAndNeighbors(at row: Int, column: Int) {
        // Выбираем центральную ячейку
        selectCell(at: row, column: column)
        
        // Выбираем соседние ячейки (слева, справа, сверху, снизу)
        let neighbors = getNeighborPositions(for: row, column: column)
        
        for (neighborRow, neighborColumn) in neighbors {
            selectCell(at: neighborRow, column: neighborColumn)
        }
    }
    
    /// Выбор конкретной ячейки
    private func selectCell(at row: Int, column: Int) {
        guard isValidPosition(row: row, column: column) else { return }
        
        let cell = gameField[row][column]
        gameField[row][column].isSelected = true
        
        delegate?.didSelectCell(
            at: row,
            column: column,
            cellType: cell.type,
            number: cell.number,
            isSelected: true
        )
        delegate?.didUpdateCellSelection(at: row, column: column, isSelected: true)
    }
    
    /// Получение позиций соседних ячеек (слева, справа, сверху, снизу)
    private func getNeighborPositions(for row: Int, column: Int) -> [(row: Int, column: Int)] {
        var neighbors: [(row: Int, column: Int)] = []
        
        // Слева
        if column > 0 {
            neighbors.append((row: row, column: column - 1))
        }
        
        // Справа
        if column < gridWidth - 1 {
            neighbors.append((row: row, column: column + 1))
        }
        
        // Сверху
        if row > 0 {
            neighbors.append((row: row - 1, column: column))
        }
        
        // Снизу
        if row < gridHeight - 1 {
            neighbors.append((row: row + 1, column: column))
        }
        
        return neighbors
    }
    
    /// Снятие выбора со всех ячеек
    private func deselectAllCells() {
        for row in 0..<gridHeight {
            for column in 0..<gridWidth {
                if gameField[row][column].isSelected {
                    gameField[row][column].isSelected = false
                    delegate?.didUpdateCellSelection(at: row, column: column, isSelected: false)
                }
            }
        }
    }
    
    /// Обновление количества выбранных ячеек
    private func updateSelectedCellsCount() {
        let count = getSelectedCellsCount()
        delegate?.didUpdateSelectedCellsCount(count)
    }
}

// MARK: - GameCell Model
struct GameCell {
    let type: CellType
    let number: String
    let imageName: String
    var isSelected: Bool
    
    init(type: CellType, number: String, imageName: String, isSelected: Bool = false) {
        self.type = type
        self.number = number
        self.imageName = imageName
        self.isSelected = isSelected
    }
}
