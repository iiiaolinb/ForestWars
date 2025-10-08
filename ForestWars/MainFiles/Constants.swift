//
//  Constants.swift
//  ForestWars
//
//  Created by Егор Худяев on 30.09.2025.
//

import UIKit

struct Constants {
    
    // MARK: - Button Dimensions
    struct Button {
        static let size: CGFloat = 100
        static let cornerRadius: CGFloat = 12
        static let borderWidth: CGFloat = 2
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Float = 0.3
        static let shadowOpacityPressed: Float = 0.1
        
        // ButtonAssistent properties - System Style
        static let height: CGFloat = 50
        static let textColor = UIColor.label
        static let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let minimumScaleFactor: CGFloat = 0.5
        
        // Icon properties
        static let iconSize: CGFloat = 24
        static let iconLeadingMargin: CGFloat = 16
        
        // Text properties
        static let textLeadingMargin: CGFloat = 12
        static let textTrailingMargin: CGFloat = 16
        
        // Animation properties
        static let animationDuration: TimeInterval = 0.1
        static let pressScale: CGFloat = 0.95
    }
    
    // MARK: - Label Properties
    struct Label {
        static let fontSize: CGFloat = 16
        static let fontSizeMultiplier: CGFloat = 0.15 // Размер шрифта как доля от размера кнопки
        static let minFontSize: CGFloat = 8
        static let maxFontSize: CGFloat = 20
        static let topMargin: CGFloat = 4
        static let leadingMargin: CGFloat = 4
        static let maxWidthMultiplier: CGFloat = 0.35
    }
    
    // MARK: - Image Properties
    struct Image {
        static let widthMultiplier: CGFloat = 0.4
        static let heightMultiplier: CGFloat = 0.4
        static let normalAlpha: CGFloat = 0.5
        static let selectedAlpha: CGFloat = 0.8
        static let tintColor = UIColor.white
    }
    
    // MARK: - Colors
    struct Colors {
        static let buttonBackground = UIColor.systemBlue
        static let buttonBackgroundPressed = UIColor.systemBlue.withAlphaComponent(0.7)
        static let borderNormal = UIColor.clear
        static let shadow = UIColor.black
        
        // Game buttons colors
        static let resetButtonColor = UIColor.systemOrange
        static let closeButtonColor = UIColor.systemRed
    }
    
    // MARK: - Glow Effect Properties
    struct Glow {
        static let shadowRadius: CGFloat = 8.0
        static let shadowOpacity: Float = 0.8
        static let shadowOffset = CGSize(width: 0, height: 0)
    }
    
    // MARK: - Animation Properties
    struct Animation {
        static let duration: TimeInterval = 0.2
        static let pressDuration: TimeInterval = 0.1
        static let scalePressed: CGFloat = 0.95
        static let scaleTap: CGFloat = 1.1
        
        // Shaking animation
        static let shakeDuration: TimeInterval = 0.5
        static let shakeAmplitude: CGFloat = 5.0
        static let shakeValues: [CGFloat] = [-5.0, 5.0, -5.0, 5.0, -3.0, 3.0, -2.0, 2.0, 0.0]
        
        // Unit movement animation
        static let unitMovementShakeDuration: TimeInterval = 0.5
    }
    
    // MARK: - Gesture Properties
    struct Gesture {
        static let longPressDuration: TimeInterval = 1.0
    }
    
    // MARK: - System Images
    struct SystemImages {
        static let enemy = "flame.fill"
        static let ally = "leaf.fill"
        static let neutral = "questionmark.circle.fill"
        
        // Game buttons icons
        static let resetIcon = "arrow.clockwise"
        static let closeIcon = "xmark.circle.fill"
    }
    
    // MARK: - Cell Type Properties
    struct CellType {
        static let enemyNumber = 99
        static let allyNumber = 42
        static let neutralNumber = 15
    }
    
    // MARK: - Layout Properties
    struct Layout {
        static let stackViewSpacing: CGFloat = 20
        static let stackViewMargin: CGFloat = 20
    }
    
    // MARK: - Game Buttons Properties
    struct GameButtons {
        static let width: CGFloat = 150
        static let height: CGFloat = 50
        static let topMargin: CGFloat = 20
        static let horizontalMargin: CGFloat = 40
    }
    
    // MARK: - Game Field Properties
    struct GameField {
        static let gridWidth: Int = 5
        static let gridHeight: Int = 10
        static let cellSpacing: CGFloat = 8
        static let fieldMargin: CGFloat = 20
        
        // Отступы от safe area
        static let topMargin: CGFloat = 20
        static let bottomMargin: CGFloat = 100 // Место для таб бара + кнопка
        static let horizontalMargin: CGFloat = 20
        
        // Метод для расчета размера кнопки на основе доступного пространства
        static func calculateButtonSize(for screenSize: CGSize) -> CGFloat {
            let availableWidth = screenSize.width - (horizontalMargin * 2)
            let availableHeight = screenSize.height - topMargin - bottomMargin
            
            // Рассчитываем размер кнопки с учетом промежутков между ячейками
            let horizontalSpacing = CGFloat(gridWidth - 1) * cellSpacing
            let verticalSpacing = CGFloat(gridHeight - 1) * cellSpacing
            
            let maxButtonWidth = (availableWidth - horizontalSpacing) / CGFloat(gridWidth)
            let maxButtonHeight = (availableHeight - verticalSpacing) / CGFloat(gridHeight)
            
            // Выбираем минимальный размер для квадратных кнопок
            let buttonSize = min(maxButtonWidth, maxButtonHeight)
            
            // Проверяем, что размер кнопки не отрицательный
            return max(buttonSize, 20) // Минимальный размер 20pt
        }
    }
    
    // MARK: - Text Properties
    struct Text {
        static let defaultNumber = "123"
        static let enemyType = "Враг"
        static let allyType = "Союзник"
        static let neutralType = "Нейтральный"
        static let selectedState = "ВЫБРАНА"
        static let deselectedState = "ОТМЕНЕНА"
        
        // Game buttons titles
        static let resetButtonTitle = "Reset"
        static let closeButtonTitle = "Close"
    }
}
