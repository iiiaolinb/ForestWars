//
//  ButtonAssistent.swift
//  ForestWars
//
//  Created by Егор Худяев on 02.10.2025.
//

import UIKit

class ButtonAssistent: UIButton {
    
    // MARK: - Properties
    private var buttonColor: UIColor?
    
    // MARK: - Initialization
    init(title: String, imageName: String, color: UIColor? = nil) {
        self.buttonColor = color
        super.init(frame: .zero)
        setupButton(title: title, imageName: imageName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupButton(title: String, imageName: String) {
        if #available(iOS 26.0, *) {
            setupLiquidGlassButton(title: title, imageName: imageName)
        } else {
            setupFallbackButton(title: title, imageName: imageName)
        }
        
        // Общие настройки
        heightAnchor.constraint(equalToConstant: Constants.Button.height).isActive = true
        
        // Настройка эффекта нажатия
        addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @available(iOS 26.0, *)
    private func setupLiquidGlassButton(title: String, imageName: String) {
        // Используем новый нативный glass стиль для iOS 26.0+
        // Этот стиль предоставляет встроенный liquid glass эффект
        var config = UIButton.Configuration.glass()
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        
        // Настройка цвета фона если указан
        if let color = buttonColor {
            config.background.backgroundColor = color.withAlphaComponent(0.8)
        }
        
        // Настройка иконки
        config.image = UIImage(systemName: imageName)
        config.imagePlacement = .leading
        config.imagePadding = 8
        
        // Настройка текста
        config.title = title
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = Constants.Button.font
            if let color = self.buttonColor {
                outgoing.foregroundColor = .white
            }
            return outgoing
        }
        
        // Применение конфигурации
        self.configuration = config
    }
    
    private func setupFallbackButton(title: String, imageName: String) {
        // Fallback для версий iOS ниже 26.0
        // Имитируем liquid glass эффект с помощью blur и полупрозрачности
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .medium
        
        // Настройка цвета фона если указан
        if let color = buttonColor {
            config.background.backgroundColor = color
        } else {
            config.background.backgroundColor = UIColor.systemFill
            config.background.visualEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        }
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        
        // Настройка иконки
        config.image = UIImage(systemName: imageName)
        config.imagePlacement = .leading
        config.imagePadding = 8
        
        // Настройка текста
        config.title = title
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = Constants.Button.font
            if let color = self.buttonColor {
                outgoing.foregroundColor = .white
            }
            return outgoing
        }
        
        // Применение конфигурации
        self.configuration = config
    }
    
    
    // MARK: - Actions
    @objc private func buttonPressed() {
        UIView.animate(withDuration: Constants.Button.animationDuration) {
            self.transform = CGAffineTransform(scaleX: Constants.Button.pressScale, y: Constants.Button.pressScale)
        }
    }
    
    @objc private func buttonReleased() {
        UIView.animate(withDuration: Constants.Button.animationDuration) {
            self.transform = .identity
        }
    }
}
