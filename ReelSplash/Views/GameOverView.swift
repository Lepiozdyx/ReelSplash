//
//  GameOver.swift
//  reel_splash
//
//  Created by Alexey Meleshin on 11/11/25.
//

import SwiftUI

struct GameOverView: View {
    @EnvironmentObject var playerStats: PlayerStats
    var onTryAgain: () -> Void = {}
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // ФОН: картинка на весь экран (как в MainMenu)
            Image("game_back")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .accessibilityHidden(true)

            // ЦЕНТР: рамка и её содержимое
            VStack {
                Spacer(minLength: 0)

                GeometryReader { proxy in
                    let w = proxy.size.width
                    let h = proxy.size.height

                    ZStack {
                        // Рамка с кнопкой закрытия
                        ZStack(alignment: .topTrailing) {
                            Image("menu_frame")
                                .resizable()
                                .scaledToFit()

                            Button {
                                dismiss()
                            } label: {
                                Image("close_button")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: w * 0.1)
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, w * 0)
                            .padding(.top, h * 0)
                        }

                        // Контент внутри рамки
                        VStack(spacing: h * 0.001) {

                            Image("game_over_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: h * 0.4)

                            HStack {
                                Spacer()
                                Text("Score:")
                                    .font(.custom("JustAnotherHand-Regular", size: h * 0.22))
                                    .foregroundColor(.white)
                                Text("\(playerStats.lastScore)")
                                    .font(.custom("JustAnotherHand-Regular", size: h * 0.25))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)

                            HStack {
                                Spacer()
                                Text("Best Score:")
                                    .font(.custom("JustAnotherHand-Regular", size: h * 0.22))
                                    .foregroundColor(.white)
                                Text("\(playerStats.bestScore)")
                                    .font(.custom("JustAnotherHand-Regular", size: h * 0.25))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)

                            GameOverButton(title: "Try Again", action: onTryAgain)
                                .frame(height: h * 0.18)
                        }
                        .padding(.horizontal, w * 0.1)
                        .padding(.vertical, h * 0.08)
                        .frame(width: w, height: h, alignment: .center)
                    }
                }
                .frame(maxWidth: 520)
                .padding(.horizontal, 16)
                // Немного опускаем рамку вниз, как в MainMenu
                .padding(.top, UIScreen.main.bounds.height * 0.1)

                Spacer(minLength: 0)
            }
        }
    }
}

// Кнопка с фоном из картинки "button" и текстом
private struct GameOverButton: View {
    var title: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            ZStack {
                Image("button")
                    .resizable()
                    .scaledToFit()

                Text(title)
                    .font(.custom("JustAnotherHand-Regular", size: 40))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    GameOverView()
        .environmentObject(PlayerStats())
        .preferredColorScheme(.dark)
}
