//
//  GameFieldView.swift
//  ForestWars
//
//  Created by Егор Худяев on 30.09.2025.
//

import UIKit

protocol GameFieldViewDelegate: AnyObject {
    func gameFieldCellTapped(at row: Int, column: Int, cell: CustomSquareButton)
    func gameFieldCellDoubleTapped(at row: Int, column: Int, cell: CustomSquareButton)
    func gameFieldDidFinishCreatingGrid()
}

final class GameFieldView: UIView {
    
    // MARK: - Public
    weak var delegate: GameFieldViewDelegate?
    
    private(set) var isGridCreated = false
    
    // MARK: - Private
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
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !isGridCreated, bounds.width > 0, bounds.height > 0 else { return }
        createGrid()
        isGridCreated = true
        
        print("[GameFieldView] Grid created with buttonSize = \(buttonSize), размеры поля = \(bounds.size)")
        delegate?.gameFieldDidFinishCreatingGrid()
    }
    
    // MARK: - Grid creation
    private func createGrid() {
        let gridWidth = Constants.GameField.gridWidth
        let gridHeight = Constants.GameField.gridHeight
        buttonSize = Constants.GameField.calculateButtonSize(for: bounds.size)
        cells = []
        
        for row in 0..<gridHeight {
            var rowCells: [CustomSquareButton] = []
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.alignment = .fill
            rowStack.spacing = Constants.GameField.cellSpacing
            
            for column in 0..<gridWidth {
                let cell = CustomSquareButton()
                cell.delegate = self
                cell.cellType = .neutral
                cell.setNumber(Constants.CellType.neutralNumber)
                cell.setImage(named: Constants.SystemImages.neutral)
                cell.tag = row * gridWidth + column
                
                cell.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    cell.widthAnchor.constraint(equalToConstant: buttonSize),
                    cell.heightAnchor.constraint(equalToConstant: buttonSize)
                ])
                
                rowStack.addArrangedSubview(cell)
                rowCells.append(cell)
            }
            
            cells.append(rowCells)
            stackView.addArrangedSubview(rowStack)
        }
    }
    
    // MARK: - Public
    func getCell(at row: Int, column: Int) -> CustomSquareButton? {
        guard row >= 0, row < cells.count,
              column >= 0, column < cells[row].count else { return nil }
        return cells[row][column]
    }
    
    func resetField() {
        // Сброс только визуального состояния ячеек
        // Логика генерации новых ячеек теперь в ViewModel
        for row in 0..<Constants.GameField.gridHeight {
            for column in 0..<Constants.GameField.gridWidth {
                let cell = cells[row][column]
                cell.setSelected(false)
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
    
    func addCellWithAppearAnimation(row: Int, column: Int) {
        guard let cell = getCell(at: row, column: column) else { return }
        cell.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        cell.alpha = 0.0
        let delay = 0.015 * Double(row * Constants.GameField.gridWidth + column)
        UIView.animate(
            withDuration: 0.36,
            delay: delay,
            usingSpringWithDamping: 0.66,
            initialSpringVelocity: 0.6,
            options: [.curveEaseOut],
            animations: {
                cell.transform = .identity
                cell.alpha = 1.0
            },
            completion: nil
        )
    }
}

// MARK: - CustomSquareButtonDelegate
extension GameFieldView: CustomSquareButtonDelegate {
    func customSquareButtonTapped(_ button: CustomSquareButton) {
        let row = button.tag / Constants.GameField.gridWidth
        let column = button.tag % Constants.GameField.gridWidth
        delegate?.gameFieldCellTapped(at: row, column: column, cell: button)
    }
    
    func customSquareButtonDoubleTapped(_ button: CustomSquareButton) {
        let row = button.tag / Constants.GameField.gridWidth
        let column = button.tag % Constants.GameField.gridWidth
        delegate?.gameFieldCellDoubleTapped(at: row, column: column, cell: button)
    }
    
    func hasSelectedCells() -> Bool {
        return !getSelectedCells().isEmpty
    }
}
