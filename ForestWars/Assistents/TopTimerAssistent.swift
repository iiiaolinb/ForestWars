//
//  TopTimerAssistent.swift
//  ForestWars
//
//  Created by Егор Худяев on 09.10.2025.
//

import UIKit

protocol TopTimerAssistentDelegate: AnyObject {
    func timerDidFinish()
    func timerDidUpdate(remainingTime: TimeInterval)
}

final class TopTimerAssistent: UIView {
    
    // MARK: - Properties
    weak var delegate: TopTimerAssistentDelegate?
    
    private var timer: Timer?
    private var remainingTime: TimeInterval = 0
    private var initialTime: TimeInterval = 0
    private var startTime: Date?
    private var backgroundTime: Date?
    
    // MARK: - UI Elements
    
    // Отдельные лейблы для каждой цифры
    private let firstDigitLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.monospacedDigitSystemFont(ofSize: Constants.InfoLabel.countFontSize, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.backgroundColor = .clear
        // Делаем лейбл узким (ширина 1.5 раза меньше высоты для эффекта вытянутости)
        return label
    }()
    
    private let secondDigitLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.monospacedDigitSystemFont(ofSize: Constants.InfoLabel.countFontSize, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }()
    
    private lazy var digitStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [firstDigitLabel, secondDigitLabel])
        stack.axis = .horizontal
        stack.spacing = -2 // Отрицательный spacing для близкого расположения
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopTimer()
        removeNotifications()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(digitStack)
        
        NSLayoutConstraint.activate([
            digitStack.topAnchor.constraint(equalTo: topAnchor),
            digitStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            digitStack.heightAnchor.constraint(equalToConstant: Constants.InfoLabel.height)
        ])
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func appDidEnterBackground() {
        // Сохраняем время ухода в фон
        backgroundTime = Date()
        print("Timer: Приложение ушло в фон, время: \(backgroundTime?.description ?? "nil")")
    }
    
    @objc private func appWillEnterForeground() {
        // При возврате из фона просто обновляем отображение
        // Логика времени теперь основана на реальном времени, поэтому корректировка не нужна
        print("Timer: Приложение вернулось из фона")
        
        // Обновляем отображение на основе реального времени
        updateTimerFromRealTime()
        
        backgroundTime = nil
    }
    
    // MARK: - Public API
    
    /// Запускает таймер с заданным временем
    /// - Parameter timeInSeconds: Время в секундах для отсчета
    func startTimer(timeInSeconds: TimeInterval) {
        stopTimer()
        
        initialTime = timeInSeconds
        remainingTime = timeInSeconds
        startTime = Date() // Запоминаем время запуска
        backgroundTime = nil
        
        updateTimerDisplay()
        
        // Используем более точный таймер с меньшим интервалом
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTimerFromRealTime()
        }
    }
    
    /// Останавливает таймер
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Сбрасывает таймер на начальное значение
    func resetTimer() {
        stopTimer()
        remainingTime = initialTime
        startTime = Date() // Сбрасываем время запуска
        backgroundTime = nil
        updateTimerDisplay()
    }
    
    /// Возвращает оставшееся время
    var currentTime: TimeInterval {
        return remainingTime
    }
    
    /// Проверяет, запущен ли таймер
    var isRunning: Bool {
        return timer != nil
    }
    
    // MARK: - Private Methods
    
    private func updateTimerFromRealTime() {
        guard let startTime = startTime else { return }
        
        // Вычисляем прошедшее время с момента запуска
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        // Вычисляем оставшееся время
        let newRemainingTime = max(0, initialTime - elapsedTime)
        
        // Проверяем завершение таймера до обновления отображения
        if newRemainingTime <= 0 && remainingTime > 0 {
            remainingTime = 0
            updateTimerDisplay()
            stopTimer()
            delegate?.timerDidUpdate(remainingTime: 0)
            delegate?.timerDidFinish()
            return
        }
        
        // Обновляем только если время изменилось на целую секунду
        let oldSeconds = Int(remainingTime)
        let newSeconds = Int(newRemainingTime)
        
        if oldSeconds != newSeconds {
            remainingTime = newRemainingTime
            updateTimerDisplay()
            delegate?.timerDidUpdate(remainingTime: remainingTime)
        }
    }
    
    private func updateTimerDisplay() {
        // Форматируем время в секунды (XX)
        let seconds = Int(remainingTime)
        let timeString = String(format: "%02d", seconds)
        
        // Разбиваем на отдельные цифры
        let firstDigit = String(timeString[timeString.startIndex])
        let secondDigit = String(timeString[timeString.index(after: timeString.startIndex)])
        
        // Анимируем только изменившиеся цифры
        updateDigitWithAnimation(label: firstDigitLabel, newValue: firstDigit)
        updateDigitWithAnimation(label: secondDigitLabel, newValue: secondDigit)
        
        // Изменяем цвет в зависимости от оставшегося времени
        updateTimerColor()
    }
    
    private func updateDigitWithAnimation(label: UILabel, newValue: String) {
        guard label.text != newValue else { return }
        
        let animation = CATransition()
        animation.type = .push
        animation.subtype = .fromTop
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        label.layer.add(animation, forKey: "flipTextChange")
        label.text = newValue
    }
    
    private func updateTimerColor() {
        let progress = remainingTime / initialTime
        let color: UIColor
        
        if progress <= 0.2 {
            // Красный цвет когда остается меньше 20% времени
            color = Constants.Colors.mainEnemy
        } else if progress <= 0.5 {
            // Оранжевый цвет когда остается меньше 50% времени
            color = Constants.Colors.resetButtonColor
        } else {
            // Обычный цвет
            color = .label
        }
        
        // Применяем цвет к обеим цифрам
        firstDigitLabel.textColor = color
        secondDigitLabel.textColor = color
    }
}
