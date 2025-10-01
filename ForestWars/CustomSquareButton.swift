//
//  CustomSquareButton.swift
//  ForestWars
//
//  Created by Егор Худяев on 30.09.2025.
//

import UIKit

// MARK: - Cell Type Enum
enum CellType {
    case enemy
    case ally
    case neutral
    
    var textColor: UIColor {
        switch self {
        case .enemy:
            return .systemRed
        case .ally:
            return .systemGreen
        case .neutral:
            return .darkGray
        }
    }
}

protocol CustomSquareButtonDelegate: AnyObject {
    func customSquareButtonTapped(_ button: CustomSquareButton)
}

class CustomSquareButton: UIView {
    
    // MARK: - Properties
    weak var delegate: CustomSquareButtonDelegate?
    
    var cellType: CellType = .neutral {
        didSet {
            updateTextColor()
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Text.defaultNumber
        label.textColor = .darkGray // Будет обновлен в updateTextColor()
        label.font = UIFont.boldSystemFont(ofSize: Constants.Label.fontSize)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let centerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Constants.Image.tintColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var isPressed: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    private var longPressTimer: Timer?
    private var isShaking: Bool = false
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        // Настройка основного view
        backgroundColor = Constants.Colors.buttonBackground
        layer.cornerRadius = Constants.Button.cornerRadius
        layer.shadowColor = Constants.Colors.shadow.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = Constants.Button.shadowRadius
        layer.shadowOpacity = Constants.Button.shadowOpacity
        
        // Добавление subviews
        addSubview(numberLabel)
        addSubview(centerImageView)
        
        // Настройка constraints
        setupConstraints()
        
        // Настройка жестов
        setupGestures()
        
        // Инициализация внешнего вида
        updateAppearance()
        updateTextColor()
        
        // Устанавливаем начальную прозрачность картинки
        centerImageView.alpha = Constants.Image.normalAlpha
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFontSize()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Лейбл в левом верхнем углу
            numberLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Label.topMargin),
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Label.leadingMargin),
            numberLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: Constants.Label.maxWidthMultiplier),
            
            // Картинка по центру
            centerImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Constants.Image.widthMultiplier),
            centerImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: Constants.Image.heightMultiplier)
        ])
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = Constants.Gesture.longPressDuration
        addGestureRecognizer(longPressGesture)
        
        // Разрешаем одновременное выполнение жестов
        tapGesture.require(toFail: longPressGesture)
    }
    
    // MARK: - Actions
    @objc private func buttonTapped() {
        // Переключаем состояние при нажатии
        isSelected.toggle()
        delegate?.customSquareButtonTapped(self)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            startShakingAnimation()
            // Длительное нажатие переводит только из обычного состояния в нажатое
            if !isSelected {
                isSelected = true
                delegate?.customSquareButtonTapped(self)
            }
        case .ended:
            stopShakingAnimation()
        case .cancelled:
            stopShakingAnimation()
        default:
            break
        }
    }
    
    // MARK: - Public Methods
    func setNumber(_ number: String) {
        numberLabel.text = number
    }
    
    func setImage(_ image: UIImage?) {
        centerImageView.image = image?.withRenderingMode(.alwaysTemplate)
    }
    
    func setImage(named imageName: String) {
        centerImageView.image = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
    }
    
    func getNumber() -> String {
        return numberLabel.text ?? ""
    }
    
    // MARK: - Private Methods
    private func updateAppearance() {
        UIView.animate(withDuration: Constants.Animation.duration) {
            if self.isSelected {
                // Выбранное состояние (постоянно нажатое)
                self.transform = CGAffineTransform(scaleX: Constants.Animation.scalePressed, y: Constants.Animation.scalePressed)
                self.backgroundColor = Constants.Colors.buttonBackgroundPressed
                self.layer.shadowOpacity = Constants.Button.shadowOpacityPressed
                self.layer.borderWidth = Constants.Button.borderWidth
                self.layer.borderColor = self.cellType.textColor.cgColor
                
                // Эффект свечения
                self.layer.shadowColor = self.cellType.textColor.cgColor
                self.layer.shadowRadius = Constants.Glow.shadowRadius
                self.layer.shadowOpacity = Constants.Glow.shadowOpacity
                self.layer.shadowOffset = Constants.Glow.shadowOffset
                
                // Картинка полностью видима
                self.centerImageView.alpha = Constants.Image.selectedAlpha
            } else {
                // Обычное состояние
                self.transform = .identity
                self.backgroundColor = Constants.Colors.buttonBackground
                self.layer.shadowOpacity = Constants.Button.shadowOpacity
                self.layer.borderWidth = 0
                self.layer.borderColor = Constants.Colors.borderNormal.cgColor
                
                // Убираем свечение
                self.layer.shadowColor = Constants.Colors.shadow.cgColor
                self.layer.shadowRadius = Constants.Button.shadowRadius
                self.layer.shadowOffset = CGSize(width: 0, height: 2)
                
                // Картинка полупрозрачная
                self.centerImageView.alpha = Constants.Image.normalAlpha
            }
        }
    }
    
    private func updateTextColor() {
        numberLabel.textColor = cellType.textColor
        
        // Обновляем цвет обводки и свечения, если кнопка выбрана
        if isSelected {
            layer.borderColor = cellType.textColor.cgColor
            layer.shadowColor = cellType.textColor.cgColor
        }
    }
    
    private func startShakingAnimation() {
        guard !isShaking else { return }
        isShaking = true
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = Constants.Animation.shakeDuration
        animation.values = Constants.Animation.shakeValues
        animation.repeatCount = .infinity
        layer.add(animation, forKey: "shaking")
    }
    
    private func stopShakingAnimation() {
        guard isShaking else { return }
        isShaking = false
        layer.removeAnimation(forKey: "shaking")
    }
    
    private func updateFontSize() {
        let buttonSize = min(bounds.width, bounds.height)
        let calculatedFontSize = buttonSize * Constants.Label.fontSizeMultiplier
        let clampedFontSize = max(Constants.Label.minFontSize, min(calculatedFontSize, Constants.Label.maxFontSize))
        
        numberLabel.font = UIFont.boldSystemFont(ofSize: clampedFontSize)
    }
}
