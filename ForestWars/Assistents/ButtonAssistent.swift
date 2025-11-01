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
            setupGlassButton(title: title, imageName: imageName)
        } else {
            setupFallbackButton(title: title, imageName: imageName)
        }
        
        heightAnchor.constraint(equalToConstant: Constants.Button.height).isActive = true
        
        addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @available(iOS 26.0, *)
    private func setupGlassButton(title: String, imageName: String) {
        var config = UIButton.Configuration.glass()
        config.cornerStyle = .medium
        config.image = UIImage(systemName: imageName)
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        
        if let color = buttonColor {
            config.background.backgroundColor = color.withAlphaComponent(0.8)
        }
        
        config.title = title
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: Constants.Button.font)
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineBreakMode = .byTruncatingTail
            outgoing.paragraphStyle = paragraph
            
            outgoing.foregroundColor = .label
            return outgoing
        }
        
        self.configuration = config
    }
    
    private func setupFallbackButton(title: String, imageName: String) {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .medium
        config.image = UIImage(systemName: imageName)
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        
        if let color = buttonColor {
            config.background.backgroundColor = color
        } else {
            config.background.visualEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        }
        
        config.title = title
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = Constants.Button.font
            outgoing.foregroundColor = .label
            return outgoing
        }
        
        self.configuration = config
    }
    
    // MARK: - Layout fix (главный секрет)
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // UIKit пересоздаёт titleLabel при смене состояния — переустанавливаем параметры каждый раз
        if let label = titleLabel {
            label.numberOfLines = 1
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.7
            label.lineBreakMode = .byTruncatingTail
            label.baselineAdjustment = .alignCenters
        }
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
