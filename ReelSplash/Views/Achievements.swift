//
//  Achievements.swift
//  reel_splash
//
//  Created by Alexey Meleshin on 11/11/25.
//

import SwiftUI

struct Achievements: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var playerStats: PlayerStats   // ← доступ к данным игрока

    // Иконки ачивок по "страницам"
    private let firstPageIcons = [
        "achievement_1st_icon",
        "achievement_2nd_icon",
        "achievement_3rd_icon"
    ]

    private let secondPageIcons = [
        "achievement_4th_icon",
        "achievement_5th_icon"
    ]

    @State private var currentPage: Int = 0

    // Пока что состояние "собрана / нет" живёт локально.
    // Если нужно сохранять между запусками, позже перенесём в PlayerStats + UserDefaults.
    @State private var collectedFirstPage: [Bool] = [false, false, false]
    @State private var collectedSecondPage: [Bool] = [false, false]

    var body: some View {
        ZStack {
            // Фон экрана достижений
            Image("achievement_back")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Рамка с контентом и кнопкой закрытия
            ZStack {
                Image("achievement_frame")
                    .resizable()
                    .scaledToFit()

                // Сетка ачивок
                VStack {
                    Spacer(minLength: 24)

                    HStack(spacing: 12) {
                        if currentPage == 0 {
                            // Первая "страница" — 1–3 ачивки
                            ForEach(0..<3, id: \.self) { index in
                                let achievementNumber = index + 1           // 1, 2, 3
                                let isUnlocked = playerStats.consecutiveLoginDays >= achievementNumber

                                VStack(spacing: 4) {
                                    AchievementCell(
                                        cellImageName: "achievement_cell",
                                        iconName: firstPageIcons[index],
                                        isCollected: collectedFirstPage[index]
                                    )

                                    CollectButton(
                                        isCollected: collectedFirstPage[index],
                                        isUnlocked: isUnlocked
                                    ) {
                                        collectedFirstPage[index] = true
                                    }
                                }
                            }
                        } else {
                            // Вторая "страница" — 4–5 ачивки и пустая ячейка справа
                            ForEach(0..<2, id: \.self) { index in
                                let achievementNumber = index + 4           // 4, 5
                                let isUnlocked = playerStats.consecutiveLoginDays >= achievementNumber

                                VStack(spacing: 4) {
                                    AchievementCell(
                                        cellImageName: "achievement_cell",
                                        iconName: secondPageIcons[index],
                                        isCollected: collectedSecondPage[index]
                                    )

                                    CollectButton(
                                        isCollected: collectedSecondPage[index],
                                        isUnlocked: isUnlocked
                                    ) {
                                        collectedSecondPage[index] = true
                                    }
                                }
                            }

                            // Пустая ячейка справа без кнопки
                            VStack(spacing: 4) {
                                AchievementCell(
                                    cellImageName: "achievement_empty_cell",
                                    iconName: nil,
                                    isCollected: false
                                )

                                Color.clear
                                    .frame(height: 32)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                    Spacer(minLength: 24)
                }

                // Кнопка закрытия в углу рамки
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image("close_button")
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(width: 32, height: 32)
                        .padding(16)
                    }
                    Spacer()
                }

                // Кнопка пролистывания вправо
                VStack {
                    Spacer().frame(height: 130)
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.easeInOut) {
                                currentPage = 1
                            }
                        } label: {
                            Image("swipe_right_button")
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(width: 40, height: 40)
                        .padding(.trailing, 16)
                        .opacity(currentPage == 0 ? 1 : 0)
                        .disabled(currentPage != 0)
                    }
                    Spacer()
                }

                // Кнопка пролистывания влево
                VStack {
                    Spacer().frame(height: 130)
                    HStack {
                        Button {
                            withAnimation(.easeInOut) {
                                currentPage = 0
                            }
                        } label: {
                            Image("swipe_left_button")
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(width: 40, height: 40)
                        .padding(.leading, 16)
                        .opacity(currentPage == 1 ? 1 : 0)
                        .disabled(currentPage != 1)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 32)
        }
    }
}

struct AchievementCell: View {
    let cellImageName: String
    let iconName: String?
    let isCollected: Bool

    var body: some View {
        ZStack {
            Image(cellImageName)
                .resizable()
                .scaledToFit()

            if let iconName {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .padding(30)
                    .opacity(isCollected ? 1.0 : 0.4)
            }
        }
    }
}

struct CollectButton: View {
    let isCollected: Bool
    let isUnlocked: Bool
    let action: () -> Void

    var body: some View {
        Button {
            if isUnlocked && !isCollected {
                action()
            }
        } label: {
            ZStack {
                Image("button")
                    .resizable()
                    .scaledToFit()

                Text("collect")
                    .font(.custom("JustAnotherHand-Regular", size: 18)) // ← наш шрифт
                    .foregroundColor(.white)
            }
        }
        .frame(height: 32)
        .disabled(!isUnlocked || isCollected)
        .opacity(
            isCollected
            ? 0.6            // уже собрана
            : (isUnlocked ? 1.0 : 0.4) // доступна/недоступна
        )
    }
}

#Preview {
    Achievements()
        .environmentObject(PlayerStats())
}
