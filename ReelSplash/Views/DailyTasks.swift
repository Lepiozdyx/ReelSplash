//
//  DailyTasks.swift
//  reel_splash
//
//  Created by Alexey Meleshin on 11/11/25.
//

import SwiftUI

struct DailyTasks: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var playerStats: PlayerStats
    var body: some View {
        ZStack {
            // Фон
            Image("menu_back")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Рамка с контентом и крестиком
            Image("menu_frame")
                .resizable()
                .scaledToFit()
                .overlay(
                    // Содержимое внутри рамки
                    VStack(alignment: .leading, spacing: 20) {
                        Spacer().frame(height: 60) // чтобы не прилипать к верху рамки
                        
                        DailyTaskRow(
                            imageName: "Achievement1",
                            title: "Get 50 Points",
                            isCompleted: playerStats.bestScore >= 50
                        )
                        
                        DailyTaskRow(
                            imageName: "Achievement2",
                            title: "Log in to the game 2 days in a row",
                            isCompleted: playerStats.consecutiveLoginDays >= 2
                        )
                        
                        Spacer()
                    }
                    .padding(.horizontal, 40),
                    alignment: .center
                )
                .overlay(
                    // Кнопка закрытия в правом верхнем углу рамки
                    Button(action: {
                        dismiss()
                    }) {
                        Image("close_button")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .padding(12)
                    },
                    alignment: .topTrailing
                )
                .padding()
        }
    }
}

// Одна строка задачи
struct DailyTaskRow: View {
    let imageName: String
    let title: String
    let isCompleted: Bool   // когда будет true — иконка и текст станут светлыми
    
    var body: some View {
        HStack(spacing: 16) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .opacity(isCompleted ? 1.0 : 0.4) // сейчас затемнено
            
            Text(title)
                .font(.custom("JustAnotherHand-Regular", size: 24))   // ← наш шрифт
                .foregroundColor(.white)
                .opacity(isCompleted ? 1.0 : 0.6)
            
            Spacer()
        }
    }
}

#Preview {
    DailyTasks()
        .environmentObject(PlayerStats())
}
