//
//  StartView.swift
//  reel_splash
//
//  Created by Alexey Meleshin on 11/13/25.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var playerStats: PlayerStats
    
    @State private var showGame = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Фон
            Image("menu_back")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            GeometryReader { geo in
                let frameWidth = geo.size.width * 0.8
                let frameHeight = geo.size.height * 0.6
                
                ZStack {
                    // Рамка по центру с кнопкой закрытия
                    ZStack(alignment: .topTrailing) {
                        Image("menu_frame")
                            .resizable()
                            .scaledToFit()
                            .frame(width: frameWidth, height: frameHeight * 1.5)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image("close_button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: frameWidth * 0.1)
                        }
                        // Двигается только кнопка внутри рамки
                        .padding(.top, frameHeight * 0)
                        .padding(.trailing, frameWidth * 0.2)
                    }
                    
                    // Всё содержимое на рамке
                    VStack(spacing: geo.size.height * 0.02) {
                        Spacer()
                        // Лого
                        Image("menu_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: frameHeight * 0.6)
                        
                        // Best Score
                        HStack {
                            Spacer()
                            Text("Best Score:")
                                .foregroundColor(.white)
                            Text("\(playerStats.bestScore)")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .font(.custom("JustAnotherHand-Regular",
                                      size: frameHeight * 0.18))
                        .padding(.horizontal, frameWidth * 0.3)
                        
                        // Last Score
                        HStack {
                            Spacer()
                            Text("Last Score:")
                                .foregroundColor(.white)
                            Text("\(playerStats.lastScore)")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .font(.custom("JustAnotherHand-Regular",
                                      size: frameHeight * 0.18))
                        .padding(.horizontal, frameWidth * 0.3)
                        
                        // 3 сердечка
                        HStack(spacing: frameWidth * 0.04) {
                            Image("heart_on")
                                .resizable()
                                .scaledToFit()
                            Image("heart_on")
                                .resizable()
                                .scaledToFit()
                            Image("heart_on")
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(height: frameHeight * 0.19)
                        
                        Button(action: {
                            showGame = true
                        }) {
                            ZStack {
                                Image("button")
                                    .resizable()
                                    .scaledToFit()
                                
                                Text("Start")
                                    .font(.custom("JustAnotherHand-Regular",
                                                  size: frameHeight * 0.22))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: frameWidth * 0.55,
                               height: frameHeight * 0.18)
                        
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .fullScreenCover(isPresented: $showGame) {
            GameView(onClose: {
                // Закрываем экран игры и возвращаемся к StartView
                showGame = false
            })
            .environmentObject(playerStats) // можно опустить, если PlayerStats уже в окружении выше
        }
    }
}

#Preview {
    StartView()
        .environmentObject(PlayerStats())
}
