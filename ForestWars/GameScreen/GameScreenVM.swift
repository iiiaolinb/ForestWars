//
//  GameScreenVM.swift
//  ForestWars
//
//  Created by Егор Худяев on 06.10.2025.
//

import UIKit

// MARK: - MoveResult
enum MoveResult {
    case cancelSelection
    case performMovement(sourceRow: Int, sourceColumn: Int)
}

// MARK: - GameScreenVMDelegate
protocol GameScreenVMDelegate: AnyObject {
    func didUpdateCell(at row: Int, column: Int, cellType: CellType, number: Int, buiding: Int, imageName: String)
    func didUpdateCellSelection(at row: Int, column: Int, isSelected: Bool)
    func didResetField()
    func didSelectCell(at row: Int, column: Int, cellType: CellType, number: Int, isSelected: Bool)
    func didUpdateSelectedCellsCount(_ count: Int)
    func didStartUnitMovementAnimation(at row: Int, column: Int)
    func didCompleteUnitMovement()
    func didStartDoubleTapExplosionAnimation(at row: Int, column: Int)
    func didUpdateInfoStack()
    
}

// MARK: - GameScreenVM
class GameScreenVM {
    
    // MARK: - Properties
    weak var delegate: GameScreenVMDelegate?
    
    private var gameField: [[GameCell]] = []
    private let gridWidth: Int = Constants.GameField.gridWidth
    private let gridHeight: Int = Constants.GameField.gridHeight
    
    // Отслеживание центральной выбранной ячейки
    private var currentSelectedCellPosition: (row: Int, column: Int)?
    
    var isMyTurn: Bool = true {
        willSet {
            print("GameScreenVM: ход \(newValue ? "игрока" : "соперника")")
        }
    }
    
    // MARK: - Initialization
    init() {
        // Инициализация будет вызвана из GameScreenVC после настройки UI
    }
    
    // MARK: - Public Methods
    
    /// Инициализация игрового поля по правилам
    func initializeGameField() {
        print("GameScreenVM: Инициализация игрового поля...")
        gameField = []
        
        for row in 0..<gridHeight {
            var rowCells: [GameCell] = []
            for column in 0..<gridWidth {
                let cell = createCellForPosition(row: row, column: column)
                rowCells.append(cell)
                updateDelegateForCell(cell, row: row, column: column)
            }
            gameField.append(rowCells)
        }
    }
    
    /// Сброс игрового поля по правилам
    func resetField() {
        print("GameScreenVM: Сброс игрового поля...")
        deselectAllCells()
        
        for row in 0..<gridHeight {
            for column in 0..<gridWidth {
                let cell = createCellForPosition(row: row, column: column)
                gameField[row][column] = cell
                updateDelegateForCell(cell, row: row, column: column)
            }
        }
        
        delegate?.didResetField()
        updateSelectedCellsCount()
    }
    
    /// Обработка нажатия на ячейку
    func cellTapped(at row: Int, column: Int) {
        guard isValidPosition(row: row, column: column) else { return }
        guard isValidTurnsCell(row: row, column: column) else { return }
        
        let cell = gameField[row][column]
        let hasSelectedCells = getSelectedCellsCount() > 0
        
        // Если ячейка neutral и нет выделенных ячеек - не разрешаем нажатие
        guard !(cell.type == .neutral && !hasSelectedCells) else { return }
        //если на ячейке нет юнитов, то ее нельзя выделить
        if !hasSelectedCells {
            guard cell.number > 0 else { return }
        }
        
        // Проверяем возможность перемещения
        if let moveResult = canMove(to: row, column: column, hasSelectedCells: hasSelectedCells) {
            switch moveResult {
            case .cancelSelection:
                deselectAllCells()
                updateSelectedCellsCount()
                return
            case .performMovement(let sourceRow, let sourceColumn):
                performUnitMovement(from: sourceRow, sourceColumn: sourceColumn, to: row, targetColumn: column)
                return
            }
        }
        
        // Если ячейка уже выбрана, отменяем выбор
        if cell.isSelected {
            deselectAllCells()
            updateSelectedCellsCount()
        } else {
            // Сначала снимаем выбор со всех других ячеек
            deselectAllCells()
            
            // Выбираем центральную ячейку и её соседей
            selectCellAndNeighbors(at: row, column: column)
            updateSelectedCellsCount()
        }
    }
    
    func cellDoubleTapped(at row: Int, column: Int) {
        guard isValidTurnsCell(row: row, column: column) else { return }
        upgradeBuildings(in: row, column: column)
        delegate?.didStartDoubleTapExplosionAnimation(at: row, column: column)
        delegate?.didUpdateInfoStack()
        print("Двойной тап")
    }
    
    func getCell(at row: Int, column: Int) -> GameCell? {
        guard isValidPosition(row: row, column: column) else { return nil }
        return gameField[row][column]
    }
    
    func updateCell(at row: Int, column: Int, with cell: GameCell) {
        guard isValidPosition(row: row, column: column) else { return }
        gameField[row][column] = cell
    }
    
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
        guard let position = currentSelectedCellPosition,
              isValidPosition(row: position.row, column: position.column) else {
            return nil
        }
        
        let cell = gameField[position.row][position.column]
        return (row: position.row, column: position.column, cell: cell)
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
    
    func getCellType(at row: Int, column: Int) -> CellType? {
        guard isValidPosition(row: row, column: column) else { return nil }
        return gameField[row][column].type
    }
    
    func getCellNumber(at row: Int, column: Int) -> Int? {
        guard isValidPosition(row: row, column: column) else { return nil }
        return gameField[row][column].number
    }
    
    func getCellImageName(at row: Int, column: Int) -> String? {
        guard isValidPosition(row: row, column: column) else { return nil }
        return gameField[row][column].imageName
    }
    
    func isCellSelected(at row: Int, column: Int) -> Bool {
        guard isValidPosition(row: row, column: column) else { return false }
        return gameField[row][column].isSelected
    }
    
    func getTotalUnits(of type: CellType) -> Int {
        var total = 0
        for row in gameField {
            for cell in row where cell.type == type {
                total += cell.number
            }
        }
        return total
    }
    
    func getTotalBuildings(of type: CellType) -> Int {
        var total = 0
        for row in gameField {
            for cell in row where cell.type == type {
                total += cell.buildings
            }
        }
        return total
    }
    
    func getAllCellsWithBuildings() -> [(row: Int, column: Int, buildings: Int)] {
        var cells: [(row: Int, column: Int, buildings: Int)] = []
        for rowIndex in 0..<gridHeight {
            for colIndex in 0..<gridWidth {
                let cell = gameField[rowIndex][colIndex]
                if cell.buildings > 0 {
                    if isMyTurn && cell.type == .ally {
                        cells.append((row: rowIndex, column: colIndex, buildings: cell.buildings))
                    } else if !isMyTurn && cell.type == .enemy {
                        cells.append((row: rowIndex, column: colIndex, buildings: cell.buildings))
                    }
                }
            }
        }
        return cells
    }
    
    func deselectAllCells() {
        currentSelectedCellPosition = nil
        
        for row in 0..<gridHeight {
            for column in 0..<gridWidth {
                if gameField[row][column].isSelected {
                    gameField[row][column].isSelected = false
                    delegate?.didUpdateCellSelection(at: row, column: column, isSelected: false)
                }
            }
        }
    }
    
    func toggleNextTurn() {
        isMyTurn.toggle()
    }
    
    func addUnitsToBuildings() {
        let cellsWithBuildings = getAllCellsWithBuildings()
        for (row, column, buildings) in cellsWithBuildings {
            guard let cell = getCell(at: row, column: column) else { continue }
            let unitsToAdd = getUnitsToAdd(for: buildings)
            let newNumber = cell.number + unitsToAdd
            let updatedCell = GameCell(
                type: cell.type,
                number: newNumber,
                buildings: cell.buildings,
                imageName: cell.imageName,
                isSelected: cell.isSelected
            )
            updateCell(at: row, column: column, with: updatedCell)
            delegate?.didUpdateCell(
                at: row,
                column: column,
                cellType: updatedCell.type,
                number: updatedCell.number,
                buiding: updatedCell.buildings,
                imageName: updatedCell.imageName
            )
        }
    }
    
    // MARK: - Private Methods
    
    /// Создание новой ячейки по координатам с учётом правил
    private func createCellForPosition(row: Int, column: Int) -> GameCell {
        let startBuildings = Constants.GameLogic.startBuildingCount
        let centerColumn = gridWidth / 2
        
        var cellType: CellType = .neutral
        var number = getNumberForCellType(cellType)
        var buildings = 0
        
        // Верхний край — enemy
        if isEnemyCell(row: row, column: column, centerColumn: centerColumn, startBuildings: startBuildings) {
            cellType = .enemy
            number = Constants.CellType.enemyNumber
            buildings = 1
        }
        // Нижний край — ally
        else if isAllyCell(row: row, column: column, centerColumn: centerColumn, startBuildings: startBuildings) {
            cellType = .ally
            number = Constants.CellType.allyNumber
            buildings = 1
        }
        
        let imageName = getImageNameForCellType(cellType)
        return GameCell(
            type: cellType,
            number: number,
            buildings: buildings,
            imageName: imageName,
            isSelected: false
        )
    }
    
    /// Проверка, является ли ячейка ячейкой врага
    private func isEnemyCell(row: Int, column: Int, centerColumn: Int, startBuildings: Int) -> Bool {
        if startBuildings <= gridWidth {
            // Влезает в одну строку
            let range = getBuildingColumns(center: centerColumn, count: startBuildings)
            return row == 0 && range.contains(column)
        } else {
            // Переполнение — вторая строка
            let totalInFirstRow = gridWidth
            let remaining = startBuildings - totalInFirstRow
            
            if row == 0 { return true } // вся первая строка
            if row == 1 {
                let range = getBuildingColumns(center: centerColumn, count: remaining)
                return range.contains(column)
            }
            return false
        }
    }
    
    /// Проверка, является ли ячейка ячейкой союзника
    private func isAllyCell(row: Int, column: Int, centerColumn: Int, startBuildings: Int) -> Bool {
        if startBuildings <= gridWidth {
            let range = getBuildingColumns(center: centerColumn, count: startBuildings)
            return row == gridHeight - 1 && range.contains(column)
        } else {
            let totalInFirstRow = gridWidth
            let remaining = startBuildings - totalInFirstRow
            
            if row == gridHeight - 1 { return true } // вся последняя строка
            if row == gridHeight - 2 {
                let range = getBuildingColumns(center: centerColumn, count: remaining)
                return range.contains(column)
            }
            return false
        }
    }
    
    /// Возвращает набор индексов колонок, где должны стоять здания по центру
    private func getBuildingColumns(center: Int, count: Int) -> [Int] {
        guard count > 0 else { return [] }
        
        var result: [Int] = [center]
        var left = center - 1
        var right = center + 1
        
        while result.count < count {
            if left >= 0 {
                result.append(left)
                if result.count == count { break }
            }
            if right < gridWidth {
                result.append(right)
                if result.count == count { break }
            }
            left -= 1
            right += 1
        }
        return result.sorted()
    }
    
    /// Уведомление делегата об обновлении ячейки
    private func updateDelegateForCell(_ cell: GameCell, row: Int, column: Int) {
        delegate?.didUpdateCell(
            at: row,
            column: column,
            cellType: cell.type,
            number: cell.number,
            buiding: cell.buildings,
            imageName: cell.imageName
        )
    }
    
    private func isCurrentSelectedCellEqualTo(row: Int, column: Int) -> Bool {
        guard let currentSelectedCellPosition else { return false }
        return currentSelectedCellPosition.row == row && currentSelectedCellPosition.column == column
    }
    
    private func canMove(to row: Int, column: Int, hasSelectedCells: Bool) -> MoveResult? {
        guard hasSelectedCells else { return nil }
        
        let cell = gameField[row][column]
        
        // Если ячейка neutral и не выделена - отменяем выделение
        if cell.type == .neutral && !cell.isSelected {
            return .cancelSelection
        }
        
        // Если есть выделенные ячейки - проверяем, можно ли выполнить перемещение
        if let currentSelected = getCurrentSelectedCell() {
            // Проверяем, является ли нажатая ячейка соседней для центральной
            let neighbors = getNeighborPositions(for: currentSelected.row, column: currentSelected.column)
            let isNeighbor = neighbors.contains { $0.row == row && $0.column == column }
            
            if isNeighbor {
                // Если ячейка является соседом, но не выделена - отменяем выделение
                if !cell.isSelected {
                    return .cancelSelection
                }
                // Если ячейка является соседом и выделена - выполняем перемещение
                return .performMovement(sourceRow: currentSelected.row, sourceColumn: currentSelected.column)
            }
        }
        
        return nil
    }
    
    private func isValidPosition(row: Int, column: Int) -> Bool {
        return row >= 0 && row < gridHeight && column >= 0 && column < gridWidth
    }
    
    private func isValidTurnsCell(row: Int, column: Int) -> Bool {
        if currentSelectedCellPosition == nil {
            let cell = getCell(at: row, column: column)
            if (isMyTurn && cell?.type == .ally) || (!isMyTurn && cell?.type == .enemy) {
                return true
            }
            return false
        }
        return true
    }
    
    private func getRandomCellType() -> CellType {
        let types: [CellType] = [.enemy, .ally, .neutral]
        return types.randomElement() ?? .neutral
    }
    
    private func getNumberForCellType(_ type: CellType) -> Int {
        switch type {
        case .enemy:
            return Constants.CellType.enemyNumber
        case .ally:
            return Constants.CellType.allyNumber
        case .neutral:
            return Int.random(in: 1...99)
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
    
    /// Выбор ячейки и её соседей
    private func selectCellAndNeighbors(at row: Int, column: Int) {
        // Сохраняем позицию центральной ячейки
        currentSelectedCellPosition = (row: row, column: column)
        
        // Выбираем центральную ячейку
        selectCell(at: row, column: column)
        
        // Получаем количество юнитов в центральной ячейке
        let centralCell = gameField[row][column]
        let centralUnitCount = getUnitCount(from: centralCell.number)
        
        // Выбираем соседние ячейки (слева, справа, сверху, снизу)
        let neighbors = getNeighborPositions(for: row, column: column)
        
        for (neighborRow, neighborColumn) in neighbors {
            let neighborCell = gameField[neighborRow][neighborColumn]
            let neighborUnitCount = getUnitCount(from: neighborCell.number)
            
            // Выделяем соседнюю ячейку только если количество юнитов меньше или равно центральной
            if neighborUnitCount <= centralUnitCount || neighborCell.type == centralCell.type {
                selectCell(at: neighborRow, column: neighborColumn)
            }
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
    
    /// Обновление количества выбранных ячеек
    private func updateSelectedCellsCount() {
        let count = getSelectedCellsCount()
        delegate?.didUpdateSelectedCellsCount(count)
    }
    
    /// Получение количества юнитов из номера ячейки
    private func getUnitCount(from number: Int) -> Int {
        return number
    }
    
    /// Вычисление итогового количества юнитов при перемещении
    private func calculateFinalUnitCount(from sourceType: CellType, to targetType: CellType, sourceUnits: Int, targetUnits: Int) -> Int {
        switch (sourceType, targetType) {
        case (.enemy, .enemy), (.ally, .ally):
            // Если переходим в ячейку того же типа - прибавляем юнитов
            return sourceUnits + targetUnits
        case (.enemy, .ally), (.enemy, .neutral), (.ally, .enemy), (.ally, .neutral):
            // Если переходим в ячейку другого типа - вычитаем юнитов
            return max(0, sourceUnits - targetUnits)
        case (.neutral, _):
            // Нейтральные ячейки не могут быть источником перемещения
            return targetUnits
        }
    }
    
    /// Выполнение перемещения юнитов с анимацией
    private func performUnitMovement(from sourceRow: Int, sourceColumn: Int, to targetRow: Int, targetColumn: Int) {
        // 1. Вычисляем итоговые значения юнитов
        moveUnits(from: sourceRow, sourceColumn: sourceColumn, to: targetRow, targetColumn: targetColumn)
        
        // 2. Снимаем выделение со всех ячеек
        deselectAllCells()
        updateSelectedCellsCount()
        
        // 4. Запускаем анимацию на целевой ячейке
        delegate?.didStartUnitMovementAnimation(at: targetRow, column: targetColumn)
        
        // 5. Завершаем анимацию через заданное время
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Animation.unitMovementShakeDuration) {
            self.delegate?.didCompleteUnitMovement()
        }
    }
    
    /// Перемещение юнитов между ячейками
    private func moveUnits(from sourceRow: Int, sourceColumn: Int, to targetRow: Int, targetColumn: Int) {
        
        guard isValidPosition(row: sourceRow, column: sourceColumn),
              isValidPosition(row: targetRow, column: targetColumn) else { return }
        
        let sourceCell = gameField[sourceRow][sourceColumn]
        let targetCell = gameField[targetRow][targetColumn]
        
        let sourceUnits = getUnitCount(from: sourceCell.number)
        let targetUnits = getUnitCount(from: targetCell.number)
        
        // Вычисляем итоговое количество юнитов
        let finalUnits = calculateFinalUnitCount(
            from: sourceCell.type,
            to: targetCell.type,
            sourceUnits: sourceUnits,
            targetUnits: targetUnits
        )
        
        // Обновляем целевую ячейку
        let newTargetCell = GameCell(
            type: sourceCell.type, // Целевая ячейка принимает тип источника
            number: finalUnits,
            buildings: targetCell.buildings,
            imageName: getImageNameForCellType(sourceCell.type),
            isSelected: false
        )
        
        gameField[targetRow][targetColumn] = newTargetCell
        
        // Обновляем UI целевой ячейки
        delegate?.didUpdateCell(
            at: targetRow,
            column: targetColumn,
            cellType: newTargetCell.type,
            number: newTargetCell.number,
            buiding: newTargetCell.buildings,
            imageName: newTargetCell.imageName
        )
        
        // Обновляем исходную ячейку - оставляем тот же тип, но 0 юнитов
        let updatedSourceCell = GameCell(
            type: sourceCell.type, // Сохраняем тип ячейки
            number: 0, // Устанавливаем 0 юнитов
            buildings: sourceCell.buildings,
            imageName: getImageNameForCellType(sourceCell.type),
            isSelected: false
        )
        
        gameField[sourceRow][sourceColumn] = updatedSourceCell
        
        // Обновляем UI исходной ячейки
        delegate?.didUpdateCell(
            at: sourceRow,
            column: sourceColumn,
            cellType: updatedSourceCell.type,
            number: updatedSourceCell.number,
            buiding: updatedSourceCell.buildings,
            imageName: updatedSourceCell.imageName
        )
        
        // Обновляем selection у ячеек
        for cell in [(sourceRow, sourceColumn), (targetRow, targetColumn)] {
            delegate?.didUpdateCellSelection(
                at: cell.0,
                column: cell.1,
                isSelected: false)
        }
    }
    
    private func upgradeBuildings(in row: Int, column: Int) {
        guard isValidPosition(row: row, column: column) else { return }
        
        let cell = gameField[row][column]
        
        // Вычисляем итоговое количество юнитов
        let newBuildingsLevel = max(0, min(cell.buildings + 1, 2))
        let newUnitsCount = calculateFinalUnitCount(for: newBuildingsLevel, currentCount: cell.number)
        
        // Обновляем целевую ячейку
        let newTargetCell = GameCell(
            type: cell.type,
            number: newUnitsCount,
            buildings: newBuildingsLevel,
            imageName: getImageNameForCellType(cell.type),
            isSelected: false
        )
        
        gameField[row][column] = newTargetCell
        
        // Обновляем UI целевой ячейки
        delegate?.didUpdateCell(
            at: row,
            column: column,
            cellType: newTargetCell.type,
            number: newTargetCell.number,
            buiding: newTargetCell.buildings,
            imageName: newTargetCell.imageName
        )
    }
    
    /// Вычисление итогового количества юнитов при апргрейде здания
    private func calculateFinalUnitCount(for level: Int, currentCount: Int) -> Int {
        switch level {
        case 1: currentCount - Constants.GameLogic.upgradeCostFirst
        case 2: currentCount - Constants.GameLogic.upgradeCostSecond
        default: currentCount
        }
    }
    
    private func getUnitsToAdd(for level: Int) -> Int {
        switch level {
        case 1: Constants.GameLogic.incomeFirst
        case 2: Constants.GameLogic.incomeSecond
        default: 0
        }
    }
}

    //  сделать нормальное распределение строений и юнитов на поле
