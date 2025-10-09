//
//  TopInfoLabelAssistent.swift
//  ForestWars
//
//  Created by Егор Худяев on 09.10.2025.
//

import UIKit

enum InfoLabelType {
    case ally
    case enemy
}

final class TopInfoLabelAssistent: UIView {
    
    // MARK: - Properties
    private let infoLabelType: InfoLabelType
    
    // MARK: - UI Elements
    private let infoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: Constants.SystemImages.infoLabelIconLeft)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private let unitsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Text.topInfoLabelUnitsTitle
        label.font = UIFont.boldSystemFont(ofSize: Constants.InfoLabel.titleFontSize)
        label.textColor = .label
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let unitsCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.italicSystemFont(ofSize: Constants.InfoLabel.countFontSize)
        label.textColor = .label
        label.textAlignment = .right
        label.backgroundColor = .clear
        return label
    }()
    
    private let buildingsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Text.topInfoLabelBuildingsTitle
        label.font = UIFont.boldSystemFont(ofSize: Constants.InfoLabel.titleFontSize)
        label.textColor = .label
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let buildingsCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.italicSystemFont(ofSize: Constants.InfoLabel.countFontSize)
        label.textColor = .label
        label.textAlignment = .right
        label.backgroundColor = .clear
        return label
    }()
    
    // MARK: - Internal Stacks
    
    private lazy var unitsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [unitsTitleLabel, unitsCountLabel])
        stack.axis = .horizontal
        stack.spacing = Constants.InfoLabel.spacing
        stack.alignment = .center
        stack.distribution = .fill
        unitsTitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        unitsCountLabel.setContentHuggingPriority(.required, for: .horizontal)
        unitsTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        unitsCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stack
    }()

    private lazy var buildingsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [buildingsTitleLabel, buildingsCountLabel])
        stack.axis = .horizontal
        stack.spacing = Constants.InfoLabel.spacing
        stack.alignment = .center
        stack.distribution = .fill
        buildingsTitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        buildingsCountLabel.setContentHuggingPriority(.required, for: .horizontal)
        buildingsTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        buildingsCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stack
    }()
    
    private lazy var rightInfoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [unitsStack, buildingsStack])
        stack.axis = .vertical
        stack.spacing = Constants.InfoLabel.spacing
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var topInfoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Constants.InfoLabel.spacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Init
    
    init(infoLabelType: InfoLabelType) {
        self.infoLabelType = infoLabelType
        super.init(frame: .zero)
        setupUI()
        applyTypeAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(topInfoStack)
        setupStackOrder()
        
        NSLayoutConstraint.activate([
            topInfoStack.topAnchor.constraint(equalTo: topAnchor),
            topInfoStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            topInfoStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            topInfoStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            infoImageView.widthAnchor.constraint(equalToConstant: Constants.InfoLabel.height),
            infoImageView.heightAnchor.constraint(equalTo: infoImageView.widthAnchor)
        ])
    }
    
    private func setupStackOrder() {
        topInfoStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if infoLabelType == .ally {
            topInfoStack.addArrangedSubview(infoImageView)
            topInfoStack.addArrangedSubview(rightInfoStack)
        } else {
            topInfoStack.addArrangedSubview(rightInfoStack)
            topInfoStack.addArrangedSubview(infoImageView)
        }
    }
    
    private func applyTypeAppearance() {
        switch infoLabelType {
        case .ally:
            infoImageView.tintColor = Constants.Colors.mainAlly
        case .enemy:
            infoImageView.tintColor = Constants.Colors.mainEnemy
        }
    }
    
    // MARK: - Public API

    func updateUnits(count: Int) {
        animateLabelChange(label: unitsCountLabel, newText: "\(count)")
    }

    func updateBuildings(count: Int) {
        animateLabelChange(label: buildingsCountLabel, newText: "\(count)")
    }

    // MARK: - Private Animations

    private func animateLabelChange(label: UILabel, newText: String) {
        guard label.text != newText else { return }

        let animation = CATransition()
        animation.type = .push
        animation.subtype = .fromTop
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // Добавляем анимацию
        label.layer.add(animation, forKey: "flipTextChange")
        label.text = newText
    }
}
