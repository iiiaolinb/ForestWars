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
    }
    
    // MARK: - Label Properties
    struct Label {
        static let fontSize: CGFloat = 16
        static let topMargin: CGFloat = 8
        static let leadingMargin: CGFloat = 8
        static let maxWidthMultiplier: CGFloat = 0.4
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
    }
    
    // MARK: - Cell Type Properties
    struct CellType {
        static let enemyNumber = "99"
        static let allyNumber = "42"
        static let neutralNumber = "15"
    }
    
    // MARK: - Layout Properties
    struct Layout {
        static let stackViewSpacing: CGFloat = 20
        static let stackViewMargin: CGFloat = 20
    }
    
    // MARK: - Text Properties
    struct Text {
        static let defaultNumber = "123"
        static let enemyType = "Враг"
        static let allyType = "Союзник"
        static let neutralType = "Нейтральный"
        static let selectedState = "ВЫБРАНА"
        static let deselectedState = "ОТМЕНЕНА"
    }
}
