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
            return Constants.Colors.mainEnemy
        case .ally:
            return Constants.Colors.mainAlly
        case .neutral:
            return Constants.Colors.mainNeutrlal
        }
    }
}

protocol CustomSquareButtonDelegate: AnyObject {
    func customSquareButtonTapped(_ button: CustomSquareButton)
    func customSquareButtonDoubleTapped(_ button: CustomSquareButton)
    func hasSelectedCells() -> Bool
}

class CustomSquareButton: UIView {
    
    // MARK: - Properties
    weak var delegate: CustomSquareButtonDelegate?
    
    var cellType: CellType = .neutral {
        didSet {
            updateTextAndBuildingColor()
        }
    }
    
    var buildingLevel: Int = 0 {
        didSet {
            updateBuildingLevel()
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
    
    private let buildingImageView1: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.tintColor = .clear
        return imageView
    }()

    private let buildingImageView2: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.tintColor = .clear
        return imageView
    }()

    private lazy var buildingStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [buildingImageView1, buildingImageView2])
        stack.axis = .horizontal
        stack.spacing = Constants.BuildingStackConstants.spacing
        stack.alignment = .top
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var isPressed: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    private weak var longPressTimer: Timer?
    private weak var singleTapTimer: Timer?
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
        
        addSubview(numberLabel)
        addSubview(centerImageView)
        addSubview(buildingStack)
        
        setupConstraints()
        setupGestures()
        updateAppearance()
        updateTextAndBuildingColor()
        setupBuildingImages()
        
        // Устанавливаем начальную прозрачность картинки
        centerImageView.alpha = Constants.Image.normalAlpha
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFontSize()
        layoutIfNeeded()
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
            centerImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: Constants.Image.heightMultiplier),
            
            // buildingStack в правом верхнем углу
            buildingStack.topAnchor.constraint(equalTo: topAnchor, constant: Constants.BuildingStackConstants.margins),
            buildingStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.BuildingStackConstants.margins)
        ])
        
        // Адаптивный размер иконок
        buildingImageView1.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Constants.BuildingStackConstants.iconSizeMultiplier).isActive = true
        buildingImageView1.heightAnchor.constraint(equalTo: buildingImageView1.widthAnchor).isActive = true
        
        buildingImageView2.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Constants.BuildingStackConstants.iconSizeMultiplier).isActive = true
        buildingImageView2.heightAnchor.constraint(equalTo: buildingImageView2.widthAnchor).isActive = true
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = Constants.Gesture.longPressDuration
        addGestureRecognizer(longPressGesture)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            if let timer = singleTapTimer {
                // Второй тап произошёл до таймера → двойное нажатие
                timer.invalidate()
                singleTapTimer = nil
                
                isUpgradeAvailable() ? buttonDoubleTapped() : nil
            } else {
                // Первый тап → ставим короткий таймер
                singleTapTimer = Timer.scheduledTimer(withTimeInterval: Constants.Gesture.secondTapWaitingDuration, repeats: false) { [weak self] _ in
                    guard let self = self else { return }
                    self.buttonTapped()
                    self.singleTapTimer = nil
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            startShakingAnimation()
            // Длительное нажатие - уведомляем делегата, состояние изменится через ViewModel
            if !isSelected {
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
    func setNumber(_ number: Int) {
        numberLabel.text = String(number)
    }
    
    func setBuidings(_ number: Int) {
        setBuildingLevel(number)
    }
    
    func setImage(_ image: UIImage?) {
        centerImageView.image = image?.withRenderingMode(.alwaysTemplate)
    }
    
    func setImage(named imageName: String) {
        centerImageView.image = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
    }
    
    func getNumber() -> Int {
        return Int(numberLabel.text ?? "0") ?? 0
    }
    
    func setSelected(_ selected: Bool) {
        isSelected = selected
    }
    
    func startUnitMovementAnimation() {
        startUnitMovementShakingAnimation()
    }
    
    func stopUnitMovementAnimation() {
        stopShakingAnimation()
    }
    
    func playDoubleTapExplosionAnimation() {
        // 🔸 Эмиттер частиц
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: bounds.width * 0.1, height: bounds.height * 0.1)
        
        // 🔸 Конфигурация частиц
        let cell = CAEmitterCell()
        cell.contents = UIImage(systemName: "circle.fill")?.withRenderingMode(.alwaysTemplate).cgImage
        cell.birthRate = 80
        cell.lifetime = 0.4
        cell.velocity = 150
        cell.velocityRange = 50
        cell.scale = 0.05
        cell.scaleRange = 0.02
        cell.alphaSpeed = -2.0
        cell.emissionRange = .pi * 2
        cell.color = cellType.textColor.cgColor

        emitter.emitterCells = [cell]
        layer.addSublayer(emitter)

        // 🔸 Убираем слой через 0.4 сек
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            emitter.birthRate = 0
            emitter.removeFromSuperlayer()
        }

        // 🔸 Дополнительная короткая "вспышка" ячейки
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.backgroundColor = self.cellType.textColor.withAlphaComponent(0.3)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
                self.backgroundColor = Constants.Colors.buttonBackground
            }
        }
    }
    
    // MARK: - Private Methods
    private func buttonTapped() {
        delegate?.customSquareButtonTapped(self)
    }
    
    private func buttonDoubleTapped() {
        guard cellType != .neutral else { return }
        delegate?.customSquareButtonDoubleTapped(self)
    }
    
    private func setBuildingLevel(_ level: Int) {
        buildingLevel = max(0, min(level, 2)) // защита от некорректных значений
    }
    
    private func isUpgradeAvailable() -> Bool {
        guard buildingLevel < 2 else { return false }
        guard let delegate, !delegate.hasSelectedCells() else { return false }
        
        let units = getNumber()
        switch buildingLevel {
        case 0:
            return units >= Constants.GameLogic.upgradeCostFirst
        case 1:
            return units >= Constants.GameLogic.upgradeCostSecond
        default:
            return false
        }
    }
    
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
    
    private func updateTextAndBuildingColor() {
        numberLabel.textColor = cellType.textColor
        buildingImageView1.tintColor = cellType.textColor
        buildingImageView2.tintColor = cellType.textColor
        
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
    
    private func startUnitMovementShakingAnimation() {
        guard !isShaking else { return }
        isShaking = true
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = Constants.Animation.unitMovementShakeDuration
        animation.values = Constants.Animation.shakeValues
        animation.repeatCount = 1 // Один раз для перемещения
        layer.add(animation, forKey: "unitMovementShaking")
    }
    
    private func stopShakingAnimation() {
        guard isShaking else { return }
        isShaking = false
        layer.removeAnimation(forKey: "shaking")
        layer.removeAnimation(forKey: "unitMovementShaking")
    }
    
    private func updateFontSize() {
        let buttonSize = min(bounds.width, bounds.height)
        let calculatedFontSize = buttonSize * Constants.Label.fontSizeMultiplier
        let clampedFontSize = max(Constants.Label.minFontSize, min(calculatedFontSize, Constants.Label.maxFontSize))
        
        numberLabel.font = UIFont.boldSystemFont(ofSize: clampedFontSize)
    }
    
    private func setNumberLabelText(_ number: Int) {
        numberLabel.text = String(number)
    }
    
    private func setupBuildingImages() {
        let buildingImage = UIImage(systemName: Constants.BuildingStackConstants.iconName)?.withRenderingMode(.alwaysTemplate)
        buildingImageView1.image = buildingImage
        buildingImageView2.image = buildingImage
    }
    
    private func updateBuildingLevel() {
        switch buildingLevel {
        case 0:
            buildingImageView1.isHidden = true
            buildingImageView2.isHidden = true
        case 1:
            buildingImageView1.isHidden = false
            buildingImageView2.isHidden = true
        case 2:
            buildingImageView1.isHidden = false
            buildingImageView2.isHidden = false
        default:
            buildingImageView1.isHidden = true
            buildingImageView2.isHidden = true
        }
    }
}
