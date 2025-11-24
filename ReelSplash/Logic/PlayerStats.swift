//
//  PlayerStats.swift
//  reel_splash
//
//  Created by Alexey Meleshin on 11/14/25.
//

import Foundation
import Combine

/// Главная модель данных игрока (общая для всех экранов)
final class PlayerStats: ObservableObject {

    // MARK: - Scores

    /// Текущий счёт — изменяется во время игры
    @Published var currentScore: Int = 0

    /// Последний полученный счёт (например, с Game Over)
    @Published var lastScore: Int = 0

    /// Лучший счёт — хранится в UserDefaults
    @Published var bestScore: Int {
        didSet {
            UserDefaults.standard.set(bestScore, forKey: "bestScore")
        }
    }

    // MARK: - Login / Days in a row

    /// Последняя дата входа игрока (по дню, а не времени)
    @Published var lastLoginDate: Date? {
        didSet {
            if let date = lastLoginDate {
                let timestamp = date.timeIntervalSince1970
                UserDefaults.standard.set(timestamp, forKey: "lastLoginDate")
            } else {
                UserDefaults.standard.removeObject(forKey: "lastLoginDate")
            }
        }
    }

    /// Сколько дней подряд игрок заходил (стрик)
    @Published var consecutiveLoginDays: Int {
        didSet {
            UserDefaults.standard.set(consecutiveLoginDays, forKey: "consecutiveLoginDays")
        }
    }

    // MARK: - Initialization

    init() {
        let defaults = UserDefaults.standard

        // Подгружаем лучший счёт (по умолчанию 0)
        self.bestScore = defaults.integer(forKey: "bestScore")

        // Подгружаем стрик дней (по умолчанию 0)
        self.consecutiveLoginDays = defaults.integer(forKey: "consecutiveLoginDays")

        // Подгружаем дату последнего входа (если есть)
        if let timestamp = defaults.object(forKey: "lastLoginDate") as? TimeInterval {
            self.lastLoginDate = Date(timeIntervalSince1970: timestamp)
        } else {
            self.lastLoginDate = nil
        }
    }

    // MARK: - Game Logic

    /// Игрок начинает новую игру → сбрасываем текущий счёт
    func startNewGame() {
        currentScore = 0
    }

    /// Завершение игры → сохраняем последний счёт, обновляем лучший
    func finishGame(with score: Int) {
        lastScore = score
        currentScore = 0

        if score > bestScore {
            bestScore = score
        }
    }

    /// Увеличение счёта (например при правильной рыбке)
    func addPoints(_ points: Int) {
        currentScore += points
    }

    // MARK: - Login / Achievements Logic

    /// Вызывай один раз при запуске игры (например, при открытии MainMenu)
    func registerLogin() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastLoginDate {
            let lastDay = calendar.startOfDay(for: lastLoginDate)

            if let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day {
                switch daysDiff {
                case 0:
                    // Уже заходил сегодня — ничего не меняем
                    break
                case 1:
                    // Вчера заходил → продолжаем стрик
                    consecutiveLoginDays += 1
                default:
                    // Пропущено больше дня → стрик сбрасывается
                    consecutiveLoginDays = 1
                }
            }
        } else {
            // Первый вход вообще
            consecutiveLoginDays = 1
        }

        // Обновляем дату последнего входа
        lastLoginDate = today
    }

    /// Удобный хелпер для ачивок: есть ли стрик нужной длины
    func hasLoginStreak(of days: Int) -> Bool {
        return consecutiveLoginDays >= days
    }
}
