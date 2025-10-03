//
//  StartScreenVM.swift
//  ForestWars
//
//  Created by Егор Худяев on 02.10.2025.
//

import UIKit

// MARK: - Protocols
protocol StartScreenVMDelegate: AnyObject {
    func navigateToGame()
    func navigateToSettings()
    func navigateToProfile()
    func exitApplication()
    func showError(_ message: String)
}

protocol StartScreenVMProtocol: AnyObject {
    var delegate: StartScreenVMDelegate? { get set }
    func startGame()
    func openSettings()
    func openProfile()
    func exitApp()
}

// MARK: - Error Types
enum StartScreenError: LocalizedError {
    case gameNotReady
    case settingsUnavailable
    case profileUnavailable
    
    var errorDescription: String? {
        switch self {
        case .gameNotReady:
            return "Игра не готова к запуску"
        case .settingsUnavailable:
            return "Настройки недоступны"
        case .profileUnavailable:
            return "Профиль недоступен"
        }
    }
}

// MARK: - StartScreenVM
class StartScreenVM: StartScreenVMProtocol {
    
    // MARK: - Properties
    weak var delegate: StartScreenVMDelegate?
    
    // MARK: - Initialization
    init() {
        // Инициализация ViewModel
    }
    
    // MARK: - Public Methods
    func startGame() {
        do {
            try validateGameStart()
            print("Начать игру нажата")
            delegate?.navigateToGame()
        } catch {
            handleError(error)
        }
    }
    
    func openSettings() {
        do {
            try validateSettingsAccess()
            print("Настройки нажата")
            delegate?.navigateToSettings()
        } catch {
            handleError(error)
        }
    }
    
    func openProfile() {
        do {
            try validateProfileAccess()
            print("Профиль нажата")
            delegate?.navigateToProfile()
        } catch {
            handleError(error)
        }
    }
    
    func exitApp() {
        print("Выход нажата")
        delegate?.exitApplication()
    }
    
    // MARK: - Private Methods
    private func validateGameStart() throws {
        // Здесь может быть логика проверки готовности к игре
        // Например, проверка сохранений, настроек и т.д.
        let isGameReady = true // Заглушка для демонстрации
        
        if !isGameReady {
            throw StartScreenError.gameNotReady
        }
    }
    
    private func validateSettingsAccess() throws {
        // Здесь может быть логика проверки доступности настроек
        let isSettingsAvailable = true // Заглушка для демонстрации
        
        if !isSettingsAvailable {
            throw StartScreenError.settingsUnavailable
        }
    }
    
    private func validateProfileAccess() throws {
        // Здесь может быть логика проверки доступности профиля
        let isProfileAvailable = true // Заглушка для демонстрации
        
        if !isProfileAvailable {
            throw StartScreenError.profileUnavailable
        }
    }
    
    private func handleError(_ error: Error) {
        let errorMessage = error.localizedDescription
        print("Ошибка: \(errorMessage)")
        delegate?.showError(errorMessage)
    }
}
