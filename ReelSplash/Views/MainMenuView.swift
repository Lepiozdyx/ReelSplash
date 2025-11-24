//
//  MainMenu.swift
//  reel_splash
//
//  Created by Alexey Meleshin on 11/11/25.
//

import SwiftUI

struct MainMenuView: View {
    @State private var showStart = false
    @State private var showSettings = false
    @State private var showAchievements = false
    @State private var showDailyTasks = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            // ФОН: картинка на весь экран
            Image("menu_back")
                .resizable()
                .scaledToFill()   // заполняет экран; при несоответствии аспектов — чуть обрежет
                .ignoresSafeArea()
                .accessibilityHidden(true)

            // ЦЕНТР: рамка и её содержимое, теперь по центру вертикали с равным отступом сверху и снизу
            VStack {
                Spacer(minLength: 0)

                ZStack {
                    Image("menu_frame")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 520)
                        .padding(.horizontal, 16)

                    GeometryReader { proxy in
                        let w = proxy.size.width
                        let h = proxy.size.height

                        VStack(spacing: h * 0.05) {
                            // ЛОГО ещё крупнее
                            Image("menu_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: h * 0.5)

                            // КНОПКИ
                            MenuImageButton(title: "Play", action: {
                                showStart = true
                            })
                            .frame(height: h * 0.13)

                            MenuImageButton(title: "Achievements", action: {
                                showAchievements = true
                            })
                            .frame(height: h * 0.13)

                            MenuImageButton(title: "Settings", action: {
                                showSettings = true
                            })
                            .frame(height: h * 0.13)
                        }
                        .padding(.horizontal, w * 0.10)
                        .padding(.vertical, h * 0.08)
                        .frame(width: w, height: h, alignment: .center)
                    }
                }
                // опускаем рамку вниз — мягко, без хардкода
                .padding(.top, UIScreen.main.bounds.height * 0.05)

                Spacer(minLength: 0)
            }

            // КНОПКА INFO: в углу ФОНА (а не рамки)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: onInfo) {
                        Image("info_button")
                    }
                    .buttonStyle(.plain)
                    .padding(16)
                }
            }
        }
        .fullScreenCover(isPresented: $showStart) {
            StartView()
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showAchievements) {
            Achievements()
        }
        .fullScreenCover(isPresented: $showDailyTasks) {
            DailyTasks()
        }
        .onAppear {
            // При первом появлении меню пробуем запустить музыку.
            // Если пользователь раньше выключил её (isOn = false),
            // play() ничего не сделает благодаря проверке внутри менеджера.
            BackgroundMusic.shared.play()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                BackgroundMusic.shared.play()
            case .inactive, .background:
                BackgroundMusic.shared.pause()
            @unknown default:
                BackgroundMusic.shared.pause()
            }
        }
    }

    private func onInfo() {
        showDailyTasks = true
    }
}

// Кнопка с фоном из картинки "button" и крупным текстом
private struct MenuImageButton: View {
    var title: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            ZStack {
                Image("button")
                    .resizable()
                    .scaledToFit()
                Text(title)
                    .font(.custom("JustAnotherHand-Regular", size: 50))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        // Можно добавить доступность:
        .accessibilityLabel(Text(title))
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    MainMenuView()
        .environmentObject(PlayerStats())
        .preferredColorScheme(.dark)
}
